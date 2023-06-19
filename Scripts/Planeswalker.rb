class Planeswalker < Unit
  # Mostly here to easily differentiate main battlers vs monsters and tokens
  # could potentially handle planeswalker limited stuff
  
  # Each planeswalker has its own subclass
  # class Name < Planeswalker

  # Each planeswalker should have its own SELF_DATA hash
  # and update the Unit_Ability methods

  # *outside* the class definition, register the planeswalker with
  # register_planeswalker(:Planeswalker_Name, cost#)
  # so the game will be able to add the planeswalker to circulation
end

module AbilityLibrary
  attr_accessor :stacks
  
  def ability_aim(key=@name)
    aim = $ability_aims[key]
    return [:aggro, 3] unless aim
    return aim
  end
  
  def custom_aim(key=@name, range=1)
    return method($custom_aims[key]).call(range)
  end
  
  def ability_area(key=@name)
    area = $ability_areas[key]
    return [:aggro, 0] unless area
    return area
  end
  
  def custom_area(key, targetHex, range)
    return method($custom_areas[key]).call(targetHex, range)
  end
  
  def ally_type(key=@name)
    return $ability_ally[key]
  end

  def ability_script(target_info, mana_cost, key=@name)
    method_name = $ability_methods[key]
    return unless method_name
    method(method_name).call(target_info, mana_cost)
  end
end

#register_planeswalker(Unit, [:aggro, 3], [:aggro, 0])
=begin
{
  "Unit": [:aggro, 3],
  "Alexa": []
}
{
  "Unit": [:aggro, 0],
  "Alexa": []
}
{
  "Unit": :ability_script_Unit,
  "Alexa": :ability_script_Alexa
}

=end