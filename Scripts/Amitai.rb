class Amitai < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Amitai",
      :display    => "Amitai Eliahu",
      :cost       => 5,
      :synergy    => [:CHRONOMANCER, :CLERIC],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :starting_mana => 40,
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
end

module AbilityLibrary
  def ability_script_amitai(target_info, mana_cost=@ability_cost)
    if $slow_match != @owner.match.id
      $slow_match = @owner.match.id
    end

    @stacks[:amitai] = @owner.match.id
    @ability_cost = -1

    run = 1.5*fps
    face = new_animation_sprite
    face.bitmap = RPG::Cache.icon("Ability/Chronomancer/clock.png")
    face.ox = face.center_x
    face.oy = face.center_y
    face.y = @sprite.midpoint_y - 90
    face.x = @sprite.midpoint_x
    face.z = @sprite.z+30
    face.add_wait(run)
    face.add_dispose
    
    minute = new_animation_sprite
    minute.bitmap = RPG::Cache.icon("Ability/Chronomancer/minute.png")
    minute.ox = minute.center_x
    minute.oy = minute.center_y
    minute.y = @sprite.midpoint_y - 90
    minute.x = @sprite.midpoint_x
    minute.z = @sprite.z+32
    minute.add_spin(-15, run/4, 1)
    minute.add_spin(-8, run/2, 2)
    minute.add_spin(-2, run)
    minute.add_dispose
    
    hour = new_animation_sprite
    hour.bitmap = RPG::Cache.icon("Ability/Chronomancer/hour.png")
    hour.ox = minute.center_x
    hour.oy = minute.center_y
    hour.y = @sprite.midpoint_y - 90
    hour.x = @sprite.midpoint_x
    hour.z = @sprite.z+31
    minute.add_spin(-1, run/4, 1)
    minute.add_spin(-1, run/2, 2)
    minute.add_spin(-1, run)
    hour.add_dispose
  end
end

register_planeswalker(Amitai)
