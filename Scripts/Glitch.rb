class Glitch < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Glitch",
      :cost       => 5,
      :synergy    => [:BARD, :CONVERGENT],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [0.7, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [850, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:aggro, 2]
  end
  
  def self.ability_area
    return [:burst, 2]
  end
  
  def attack_sprite_file(attack_keys)
    cs = ["w", "u", "p", "r", "g", "m"]
    c = rand(cs.length)
    return "Weapon/"+cs[c]+"ray.png"
  end
  
end

module AbilityLibrary
  def ability_script_glitch(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    abil_damage = 100 * mana_amp * (get_value(:ARCHIVE)/100)
    rainbow = ["light", "red", "orange", "yellow", "green", "blue", "purple"]

    for hex in target_info[0]
      rspr = new_animation_sprite
      i = target_info[0].index(hex)
      rspr.bitmap = RPG::Cache.icon("Ability/Hexes/"+rainbow[i%7]+".png")
      rspr.opacity = 0
      rspr.x = hex.pixel_x
      rspr.y = hex.pixel_y
      rspr.z = @sprite.z + 20
      rspr.add_wait(0.8*fps)
      rspr.add_damage(Damage_Ability.new(self, hex.battler, abil_damage), "enemy")
      rspr.add_dispose()
    end

    angler = {
      :bottom_right => 28,
      :bottom_left => -28,
      :top_right => 152,
      :top_left => -152,
      :bottom => 45,
      :left => -90,
      :right => 90,
      :top => -180,
      :bottom => 0
    }
    c_ar = ["w", "u", "b", "r", "g"]
    main_angle = angler[target_info[3]]
    un = main_angle / main_angle.abs()
    off_a = [un*10, -un*7, un*5, -un*3, 0]
    del_a = [0, 0.1, 0.2, 0.4, 0.8]
    for i in 0..4
      wave_spr = new_animation_sprite
      wave_spr.bitmap = RPG::Cache.icon("Ability/Glitch/"+c_ar[i]+"ripple.png")
      wave_spr.ox = 64
      wave_spr.x = @current_hex.midpoint_x
      wave_spr.y = @current_hex.midpoint_y
      wave_spr.z = @sprite.z + 22
      wave_spr.angle = main_angle + off_a[i]
      wave_spr.visible = false
      wave_spr.add_wait(del_a[i]*fps)
      wave_spr.switch_visible()
      x = 120*Math.sin(to_radians(wave_spr.angle))
      y = 120*Math.cos(to_radians(wave_spr.angle))
      wave_spr.add_translate(x, y, 0.5*fps)
      wave_spr.add_dispose()
    end
  end
end

register_planeswalker(Glitch)