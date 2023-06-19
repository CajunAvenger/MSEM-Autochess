# The attribute handling of a unit
class Unit
  
  include AbilityLibrary
  
  # get current life remaining
  def get_life
   return get_value(:MAX_LIFE)-@current_damage
  end
 
  def mana_amp
    return (get_value(:MANA_AMP)+@temp_amp) / 100
  end
 
  # get current Power, Toughness, etc
  # also gets Cloak etc
  def get_value(sym, bonus=0, bonus_multi=0)
    case sym
    when :LIFE
      return get_life()
    when :MANA
      return @mana
    when :LEVEL
      return @level
    end
    vals = get_impact_nums(sym)
    base = get_base(sym) + vals[:bonus] + bonus
    multi = 1 + vals[:multi] + bonus_multi
    #multi = 0 if multi < 0
    multi = 1/(2.5 - multi) if multi < 0.5
    return base*multi
  end
  
  # get bonus and multi of particular key from impacts
  def get_impact_nums(sym)
    hash = {
      :bonus => 0,
      :multi => 0
    }
    syms = fetch_syms(sym)
    
    if @impacts.include?(syms[0])
      looper = false
      unless $loop_guard[:active]
        looper = true
        $loop_guard = {:active => true}
      end
      for imp in @impacts[syms[0]]
        #console.log(imp.source.id)
        hash[:bonus] += imp.get_value()
      end
      $loop_guard[:active] = false if looper
    end
    
    if @impacts.include?(syms[1])
      looper = false
      unless $loop_guard[:active]
        looper = true
        $loop_guard = {:active => true}
      end
      for imp in @impacts[syms[1]]
        #console.log(imp.source.id)
        hash[:multi] += imp.get_value()
      end
      $loop_guard[:active] = false if looper
    end
    return hash
  end

  # get this unit's base stat based on their level
  def get_base(sym)
    val = 0
    case sym
    when :COST
      val = @cost
    when :RANGE
      val = @range[@level-1]
    when :POWER
      val = @power[@level-1]
    when :MULTI
      val = @multistrike[@level-1]
    when :HASTE
      val = @haste[@level-1]
    when :MANA_AMP
      val = @mana_amp[@level-1]
    when :ARCHIVE
      val = @archive[@level-1]
    when :TOUGHNESS
      val = @toughness[@level-1]
    when :WARD
      val = @ward[@level-1]
    when :MAX_LIFE
      val = @max_life[@level-1]
    end
    return val
  end
  
  # get [:KEY, :KEY_MULTI] of a key
  def fetch_syms(sym)
    val = [sym, :Blank]
    case sym
    when :RANGE
      val = [:RANGE, :RANGE_MULTI]
    when :RANGE_MULTI
      val = [:RANGE, :RANGE_MULTI]
    when :POWER
      val = [:POWER, :POWER_MULTI]
    when :POWER_MULTI
      val = [:POWER, :POWER_MULTI]
    when :MULTI
      val = [:MULTI, :MULTI_MULTI]
    when :MULTI_MULTI
      val = [:MULTI, :MULTI_MULTI]
    when :HASTE
      val = [:HASTE, :HASTE_MULTI]
    when :HASTE_MULTI
      val = [:HASTE, :HASTE_MULTI]
    when :MANA_AMP
      val = [:MANA_AMP, :MANA_AMP_MULTI]
    when :MANA_AMP_MULTI
      val = [:MANA_AMP, :MANA_AMP_MULTI]
    when :ARCHIVE
      val = [:ARCHIVE, :ARCHIVE_MULTI]
    when :ARCHIVE_MULTI
      val = [:ARCHIVE, :ARCHIVE_MULTI]
    when :TOUGHNESS
      val = [:TOUGHNESS, :TOUGHNESS_MULTI]
    when :TOUGHNESS_MULTI
      val = [:TOUGHNESS, :TOUGHNESS_MULTI]
    when :WARD
      val = [:WARD, :WARD_MULTI]
    when :WARD_MULTI
      val = [:WARD, :WARD_MULTI]
    when :MAX_LIFE
      val = [:MAX_LIFE, :MAX_LIFE_MULTI]
    when :MAX_LIFE_MULTI
      val = [:MAX_LIFE, :MAX_LIFE_MULTI]
    when :LIFESTEAL
      val = [:LIFESTEAL, :LIFESTEAL_MULTI]
    when :LIFESTEAL_MULTI
      val = [:LIFESTEAL, :LIFESTEAL_MULTI]
    end
    return val
  end
  
  # apply toughness then emit we're taking damage so listeners can modify
  def incoming_damage_modifier(damage_event)
    damage_event.clear_unit(self) if get_value(:INVULNERABLE) > 0
    damage_event.clear_unit(self) if check_immune(damage_event.keys)
    emit(:IncomingDamage, damage_event)
  end
    
  # return how many component, completed, and rare artifacts we're wielding
  def artifact_counts
    comp = 0
    compl = 0
    rar = 0
    for artifact in @artifacts do
      comp += 1 if artifact.is_component()
      compl += 1 if artifact.is_completed()
      rar += 1 if artifact.is_rare()
    end
    arti_hash = {
      :component => comp,
      :completed => compl,
      :rare => rar
    }
    return arti_hash
  end
    
  # return how many item slots we have left
  def remaining_item_slots
    return 3 - @artifacts.length
  end
  
  def clock_ticker
    # our timed buffs were already ticked
    # if we're still stunned, skip
    @mana_cooldown -= 1 if @mana_cooldown > 0
    sv = get_value(:STUN)
    if sv > 0
      return :stunned
    end
    # ticks since our last attack
    @ticker += 1.0
    return if @impacts.include?(:Casting)
    haste = get_value(:HASTE)
    return false if haste <= 0
    # if our ticker is greater than our haste, attack
    attack_ticks = tps/haste
    if ticker >= attack_ticks.floor()
      @ticker -= attack_ticks
      return true
    end
    return false
  end
  
  def mana_ticker
    return false if @ability_cost < 0
    return @cached_cost <= @mana if @cached_cost
    return @ability_cost <= @mana
  end
  
  def is_benched?
    return true unless @current_hex
    return @current_hex.is_bench
  end
  
  def aerial
    return get_value(:Aerial)
  end
  
  def movement
    return 0 if @rooted > 0
    return 2+@move if aerial > 0
    return 1+@move
  end
  
  def init_ticker(start=false)
    haste = get_value(:HASTE)
    if haste != 0
      @ticker = tps/haste
    else
      @ticker = 0
    end
    if start
      base = get_base_stats
      @ticker -= base[:slow_start] if base.include?(:slow_start)
    end
    
  end
  
  def reset_state
    if @starting_hex
      for b, buff in @buffs
        buff.clear_buff() unless buff.is_a?(Eternal)
      end
      @starting_hex.set_battler(self)
      @current_damage = 0
      @mana = get_base_stats[:starting_mana] || 0
      @ability_cost = get_base_stats[:ability_cost] || 100
      @ability_cost += get_value(:MAX_MANA)
      @ticker = 0
      @dead = false
      @deployed = false
      update_life
      update_mana
      if @owner.id == 1 and not sprite.disposed?
        @sprite.opacity = 255
        @sprite.add_fade_to(255, $frames_per_second, @sprite.add_schedule)
      end
    else
      @owner.remove_unit(self)
    end
  end

  def fps
    return $frames_per_second unless @owner
    return $frames_per_second unless @owner.match
    return $frames_per_second unless $slow_match == @owner.match.id
    return $frames_per_second if @stacks[:amitai] == @owner.match.id
    return 2 * $frames_per_second
  end
  
  def tps
    return $tick_loops * fps
  end
  
end
