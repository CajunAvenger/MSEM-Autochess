# How this unit interacts with other systems
# Equipping/unequipping artifacts etc
# Most of the time these shouldn't need to be changed
class Unit
  
  # Hexes
  def update_hex(hex, dont_trigger=false)
    old_hex = @current_hex
    if old_hex && old_hex != hex && old_hex.battler == self
      old_hex.battler = nil
    end
    @current_hex = hex
    x_pos = @current_hex.pixel_x
    y_pos = @current_hex.pixel_y
    if @owner.id == 1 || @owner.match
      @sprite.pop(:aim)
      move_time = 0.4*fps
      move_time = 1 if old_hex == nil
      @sprite.add_move_to(x_pos, y_pos, move_time)
    end
    emit(:Moved, old_hex, @current_hex, @path_cache) #unless dont_trigger
    if $processor_status != :combat_phase && old_hex && old_hex.is_bench != @current_hex.is_bench
      @owner.emit(:BoardChange, self)
      @owner.synergy_update(self)
    end
    @owner.star_up_check(self) if @current_hex.is_bench
  end
  
  def move_to_bench
    move_to = nil
    for h, hex in @owner.bench
      next unless hex.battlers.length == 0
      next unless move_to == nil
      move_to = hex
    end
    if move_to
      update_hex(move_to)
    else
      @owner.full_bench_script(self)
    end
  end
  
  # Artifacts
  def give_artifact(artifact)
    mix = nil
    console.log("comp check")
    if artifact.is_component
      for a in @artifacts
        next unless a.is_component
        mix = a
        break
      end
    end
    if mix
      new_arti = $artifacts[:build_map][mix.name][artifact.name]
      bst = new_arti.get_base_stats
      if bst[:synergy]
        return false if @synergies.include?(bst[:synergy]) && !@leech_synergies.include?(bst[:synergy])
      end
      if bst[:unique]
        return false if @owner.unique_builds.include?(new_arti)
        @owner.unique_builds.push(new_arti)
      end
      hold = artifact
      artifact.sprite.dispose
      artifact = new_arti.new(artifact)
      artifact.empower_from(hold, mix)
      mix.unequip_from()
      mix.sprite.dispose
      emit(:Upgraded, artifact)
      @artifacts[@artifacts.index(mix)] = artifact
      artifact.equip_to(self)
      emit(:EquipmentChange)
      return true
    else
      console.log(remaining_item_slots)
      return false if remaining_item_slots < artifact.use_slots()
      for i in 1..artifact.use_slots()
        @artifacts.push(artifact)
      end
      console.log("equipping")
      artifact.equip_to(self)
      emit(:Equipped, artifact)
      emit(:EquipmentChange)
      return true
    end
  end
    
  def remove_artifact(artifact)
    rem = @artifacts.delete(artifact)
    return false if rem == nil
    artifact.unequip_from()
    emit(:Unequipped, artifact)
    emit(:EquipmentChange)
    return true
  end
  
  # Buffs
  def add_buff(buff)
    @buffs[buff.id] = buff
  end
    
  def remove_buff(buff)
    @buffs.delete(buff.id)
  end
  
  # Impacts
  def add_impact(impact)
    @impacts[impact.id] = [] unless @impacts[impact.id]
    return if @impacts[impact.id].include?(impact)
    emit(:GainingImpact, impact)
    @impacts[impact.id].push(impact)
    if impact.id == :MAX_LIFE || impact.id == :INVULNERABLE || impact.id == :SHIELD
      update_life
    end
  end
  
  def remove_impact(impact)
    return unless @impacts[impact.id]
    return unless @impacts[impact.id].include?(impact)
    emit(:LosingImpact, impact)
    @impacts[impact.id].delete(impact)
    @impacts.delete(impact.id) if @impacts[impact.id].empty?
    if impact.id == :MAX_LIFE || impact.id == :INVULNERABLE || impact.id == :SHIELD
      update_life
    end
    if impact.id == :MAX_LIFE
      death_check(nil)
    end
  end

  def check_taunted
    taunters = []
    taunt_hexes = []
    return [taunters, taunt_hexes] unless @impacts.include?(:TAUNT)
    for imp in @impacts[:TAUNT] do
      next unless imp.focus.current_hex
      next unless can_target?(imp.focus.current_hex)
      taunters.push(imp.focus)
      taunt_hexes.push(imp.focus.current_hex)
    end
    return [taunters, taunt_hexes]
  end
  
  def check_cloaked
    cloaked = 0
    for imp in @impacts[:CLOAK] do
      cloaked += imp.get_value()
    end
    return cloaked > 0
  end
  
  def check_immune(keys)
    keys = [keys] if keys.is_a?(String)
    for imm in @immunities do
      return true if keys.include?(imm)
    end
    return false
  end
  
  # Immunities
  def add_immunity(key)
    @immunities.push(key)
  end
  
  def remove_immunity(key, remove_all=false)
    if remove_all
      @immunities.delete(key)
    else
      ind = @immunities.find_index(key)
      @immunities.delete_at(ind)
    end
  end
  
  # Healing
  def apply_heal(impact, dont_trigger=false)
    # give our listeners a chance to edit it
    emit(:GainingLife, impact)
    # check final value is legit
    heal = impact.get_value()
    return 0 if heal <= 0
    heal = @current_damage if heal > @current_damage
    @current_damage -= heal
    # let our listeners know we gained life
    emit(:GainedLife, heal) unless dont_trigger
    update_life
    return heal
  end
  
  # non-Damage damage, usually from negative life steal
  def apply_bleed(impact, damage_event)
    bleed = impact.get_value()
    return 0 if bleed < 0
    @current_damage += bleed
    death_check(damage_event)
  end
  
  def apply_mana_heal(impact, dont_trigger=false)
    # give our listeners a chance to edit it
    emit(:GainingMana, impact)
    # check final value is legit
    heal = impact.get_value() * get_value(:ARCHIVE)/100
    return 0 if heal < 0
    @mana += heal
    # let our listeners know we gained mana
    emit(:GainedMana, heal) unless dont_trigger
    update_mana
    return heal
  end    
  
  def death_check(damage_event)
    return if get_life() > 0
    return if get_value(:INVULNERABLE) > 0
    emit(:Dying, damage_event)
    update_life
    # If we're still dead after the listeners have done their thing, clear
    unless get_life() > 0
      old_hex = @current_hex
      @dead = true
      loot_drop if @owner.is_a?(Minion_Player)
      clear_from_board
      @owner.match.counters[:deaths] += 1
      emit(:Died, self, old_hex, damage_event)
      damage_event.source.emit(:Killed, self, old_hex, damage_event) if damage_event
      lgok = damage_event.source.get_value(:LGOK)
      if lgok > 0
        damage_event.source.apply_heal(Heal.new(lgok))
      end
    end
  end
  
  def clear_from_board
    for b, buff in buffs
      buff.clear_buff() unless buff.is_a?(Eternal)
    end
    @current_hex.remove_battler if @current_hex
    if @owner.match && @owner.match.status == :running
      @owner.match.board.graveyard.push(self)
    end
    @owner.deployed.delete(self)
    sc = @sprite.add_schedule
    @sprite.add_fade_to(0, 0.4*fps, sc)
    if @sprite.subsprites.length
      for s in @sprite.subsprites
        next unless s.is_a?(Sprite_Scheduler)
        scs = s.add_schedule
        s.add_fade_to(0, 0.4*fps, scs)
        s.add_wait(0.4*fps, scs)
        s.add_dispose(scs)
      end
    end
    #@sprite.add_dispose(sc) if self.is_a?(Token)
  end
  
  def clear_unit()
    # clear hex position
    @current_hex.remove_battler
    # clear buffs
    for b, buff in @buffs do
      buff.clear_buff() unless buff.is_a?(Eternal)
    end
    # unattach artifacts
    for artifact in @artifacts
      remove_artifact(false)
    end
    # remove from synergies
    for syn in @synergy
      @owner.synergy_handlers[syn].remove_member(self)
    end
    # clear listeners
    clear_listeners()
    # remove from user's pool
    @owner.remove_unit(self)
    @dead = true
  end
  
end