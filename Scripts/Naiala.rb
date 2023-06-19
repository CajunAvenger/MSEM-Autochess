class Naiala < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Naiala",
      :cost       => 4,
      :synergy    => [:INVESTIGATOR, :AERIAL],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :starting_mana => 70,
      :pronoun    => "any"
    }
  end
  
  def self.ability_aim
    return [:aggro, 1]
  end
  
  def self.ability_area
    return [:cone, 2]
  end
  
end

module AbilityLibrary
  def ability_script_naiala(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    stun_dura = 2 * mana_amp
    angler = {
      :right => 0,
      :top_right => 30,
      :top => 90,
      :top_left => 150,
      :left => 180,
      :bottom_left => 210,
      :bottom => 270,
      :bottom_right => 330
    }
    angle = angler[target_info[3]]
    cone = new_animation_sprite
    cone.bitmap = RPG::Cache.icon("Ability/naiala_cone.png")
    cone.center_on(@sprite)
    cone.ox = 0
    cone.oy = cone.center_y
    cone.angle = angle
    cone.z = @sprite.z + 25
    cone.add_fade_to(0, 0.5*fps)
    cone.add_dispose

    for h in target_info[0].reverse
      next unless h.battler
      next unless h.controller != @owner
      Debuff_Timed.new(self, h.battler, Impact.new(:STUN, 1), stun_dura)
      h.battler.current_hex.hex_in_direction(target_info[3]).set_battler(h.battler)
    end
    
  end
end

register_planeswalker(Naiala)
