# The ability information of a unit
# These will often want to be overwritten in planeswalker subclasses
class Unit
  # the method to find the primary target for this ability
  # :aggro, :ally, :on_me, :custom_ward, or :custom_unward
  # ward cost is calculated for :aggro and :custom_ward
  # number is distance away it can hit
  def self.ability_aim
    return [:aggro, 3]
  end
  # for :ally, can specify which allies to give precedence to
  # :low_N and :high_N for (ex :low_life)
  # life, mana, level, power, toughness, mana_amp
  # runs a method with the key's name so can just add new ones
  def self.ally_type
    return :low_life
  end
  # the area to collect all targets for this ability, and its range
  # :on_me, :aggro, :area, :line, :cone, :burst, :all, :none, :custom
  # :aggro is single target on @aggro
  def self.ability_area
    return [:aggro, 0]
  end
  # remove hexes from the collected targets before ward cost is calculated
  # if the restriction doesn't need to impact the ward cost
  # the check can probably be done in ability_script() instead
  def can_target?(hex)
    return true unless hex.battler
    return false if hex.battler.get_value(:FLICKER) > 0
    return true if hex.battler.owner == @owner
    return false if hex.battler.get_value(:CLOAK) > 0
    return true
  end
  # this script runs to find a primary ally for ability_aim :ally
  # can replace for a more specific ally targetting
  def find_ally(range, key=nil)
    areas = @current_hex.get_area_hexes(range, 0)
    key = :low_life if key == nil
    hash = {:hex => nil, :comp => nil}
    for hex in areas[0]
      next if hex == @current_hex
      next unless hex.battler
      next if hex.battler.owner != @owner
      self.method(key).call(hex, hash)
    end
    return @current_hex unless hash[:hex]
    return hash[:hex]
  end
  
  def low_check (hex, hash, key)
    hash[:comp] = 10000 unless hash[:comp]
    v = hex.battler.get_value(key)
    if v < hash[:comp]
      hash[:comp] = v
      hash[:hex] = hex
    end
  end
  
  def high_check (hex, hash, key)
    hash[:comp] = 0 unless hash[:comp]
    v = hex.battler.get_value(key)
    if v > hash[:comp]
      hash[:comp] = v
      hash[:hex] = hex
    end
  end
  
  def low_life (hex, hash)
    low_check(hex, hash, :LIFE)
  end
  
  def high_life (hex, hash)
    high_check(hex, hash, :LIFE)
  end
  
  def low_mana (hex, hash)
    low_check(hex, hash, :MANA)
  end
  
  def high_mana (hex, hash)
    high_check(hex, hash, :MANA)
  end
  
  def low_power (hex, hash)
    low_check(hex, hash, :POWER)
  end
  
  def high_power (hex, hash)
    high_check(hex, hash, :POWER)
  end
  
  def low_toughness (hex, hash)
    low_check(hex, hash, :TOUGHNESS)
  end
  
  def high_toughness (hex, hash)
    high_check(hex, hash, :TOUGHNESS)
  end
  
  def low_mana_amp (hex, hash)
    low_check(hex, hash, :MANA_AMP)
  end
  
  def high_mana_amp (hex, hash)
    high_check(hex, hash, :MANA_AMP)
  end
  
  def low_level (hex, hash)
    low_check(hex, hash, :LEVEL)
  end
  
  def high_level (hex, hash)
    high_check(hex, hash, :LEVEL)
  end
  
end