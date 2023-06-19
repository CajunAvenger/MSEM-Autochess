class Iviana < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Iviana",
      :cost       => 5,
      :synergy    => [:DRACONIC, :ARTIFICER],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:custom_ward, 7]
  end
  
  def self.ability_area
    return [:custom, 1]
  end
  
end

module AbilityLibrary
  def ability_script_iviana(target_info, mana_cost=@ability_cost)
    final_hex = target_info[2]
    # make sure our dash point still works
    return if final_hex.battler
    start_hex = @current_hex
    target_hex = target_info[0][0]
    path = target_info[3]
    abil_damage = 100 * mana_amp * get_value(:POWER)/65
    delay = 0.0
    step = 0.2
    # Dashes forward on a dragon, damaging enemies in her path and gaining stacking haste.
    @stacks[:iviana] = [nil, nil] unless @stacks[:iviana]
    if @stacks[:iviana][1] != @owner.match.id
      @stacks[:iviana] = [Impact.new(:HASTE_MULTI, 0.2), @owner.match.id]
      Buff.new(self, self, @stacks[:iviana][0])
    else
      @stacks[:iviana][0].amount += 0.2
    end
    
    # make a copy to manip instead of actual iviana
    clone_spr = new_animation_sprite
    clone_spr.bitmap = @sprite.bitmap
    clone_spr.x = @sprite.x
    clone_spr.y = @sprite.y
    clone_spr.z = @sprite.z + 30
    clone_spr.add_wait(step*fps)
    dragon = new_animation_sprite
    dragon.bitmap = RPG::Cache.icon("Ability/dragon_dash.png")
    dragon.z = @sprite.z + 31
    dragon.add_stick_to(clone_spr)
    clone_spr.subsprites.push(dragon)
    # make Iviana invisible and move her to the final hex
    @sprite.opacity = 0
    final_hex.set_battler(self)
    # cloak and root Iviana for the duration
    imps = [
      Impact.new(:CLOAK, 1),
      Impact.new(:Casting, 1)
    ]
    ibuff = Buff.new(self, self, imps)

    # ignite the path and charge Iviana across it
    for id in path
      h = @owner.match.board.board_map[id]
      clone_spr.add_move_to(h.pixel_x, h.pixel_y, step*fps)
      fire_spr = new_animation_sprite
      fire_spr.bitmap = RPG::Cache.icon("Ability/flame.png")
      fire_spr.x = h.pixel_x
      fire_spr.y = h.pixel_y
      fire_spr.z = @sprite.z + 29
      fire_spr.opacity = 0
      fire_spr.add_wait(delay*fps)
      fire_spr.add_fade_to(255, step/2*fps)
      fire_spr.add_damage(Damage_Ability.new(self, nil, abil_damage), "enemy")
      fire_spr.add_fading(180, 255, 4, 0.2*fps)
      fire_spr.add_dispose
      delay += step/2
    end

    clone_spr.add_move_to(final_hex.pixel_x, final_hex.pixel_y, step*fps)
    unhide = Proc.new do
      @sprite.add_fade_to(255, 1, @sprite.add_schedule)
      ibuff.clear_buff
    end
    clone_spr.add_proc(unhide)
    clone_spr.add_dispose
    sc = @sprite.add_schedule
    
  end
  
  def aim_script_iviana(range)
    aggro = nil
    
    # check if we're taunted
    taunting = check_taunted()
    taunters = taunting[0]
    
    # check if we're confused
    confused = false #get_value(:CONFUSED) > 0
    if confused && taunters.length
      ts = []
      for t in taunters
        next unless t.owner == @owner
        ts.push(t)
      end
      taunters = ts
    end
    
    # hexes we can reach and hexes we can "see"
    areas = @current_hex.get_area_hexes(range)
    a_dists = {}
    for di in areas[1]
      for h in di[:hexes]
        a_dists[h.id] = di[:dist]
      end
    end

    # find new aggro target
    # if we're taunted and a taunter is dashable, send one at random
    unless taunters.empty?
      # taunting that we can hit
      taunts_in_range = taunting[1] & areas[0]
      unless taunts_in_range.empty?
        # pick at random
        taunts_in_range.shuffle
        for t in taunts_in_range
          ns = t.get_neighbors
          # that have a free hex next to them
          for n in ns
            next if n.battler
            return [t, n, areas]
          end
        end
      end
    end
    
    # not taunted or all out of range
    # grab the furthest enemy
    d = [0, nil]
    for di in areas[1]
      for h in di[:hexes]
        next unless h.battler
        l = @current_hex.get_px_dist_to(h.battler.current_hex)
        d = [l, h] if l > d[0]
      end
    end
    return nil unless d[1]
    landing = nil
    path = @current_hex.get_burrow_to(d[1])
    for h in d[1].get_neighbors
      next if h.battler
      next if path.include?(h.id)
      landing = h
    end
    return nil unless landing
    return [d[1], landing, path]
  end
  
  def area_script_iviana(targetHex, range)
    return [[targetHex[0]], [{:dist => 0, :hexes => [targetHex[0]]}], targetHex[1], targetHex[2]]
  end
end

register_planeswalker(Iviana)
