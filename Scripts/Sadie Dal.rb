class Sadie < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Sadie",
      :display    => "Sadie Dal",
      :cost       => 2,
      :synergy    => [:SCOUT, :ARTIFICER, :CONVERGENT],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "she/they"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:area, 6]
  end
  
end

module AbilityLibrary
  def ability_script_sadie(target_info, mana_cost=@ability_cost)
    for h in target_info[0]
      next if h == @current_hex
      next unless h.controller == @owner
      vial = new_animation_sprite
      vial.bitmap = RPG::Cache.icon("Ability/gvial.png")
      vial.x = h.pixel_x
      vial.y = h.pixel_y
      vial.z = @sprite.z + 30
      vial.add_rotation(3, 0.4*fps)
      vial.add_heal(h.battler, Impact.new(:HEALING, 200*mana_amp))
      vial.add_dispose
    end
  end
end

register_planeswalker(Sadie)