class Mari < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Mari",
      :cost       => 2,
      :synergy    => [:ELDER, :MORNINGLIGHT],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => 100,
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [500, 20, 40],
      :starting_mana => 70.0,
      :mana_cooldown => 4.0,
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end

  def attack_sprite_file(attack_keys)
    return "Weapon/lray.png"
  end
  
end

module AbilityLibrary
  def ability_script_mari(target_info, mana_cost=@ability_cost)
    abil_damage = 100 * mana_amp
    z = 15
    delay1 = 0.0
    delay2 = 0.0
    
    beam_start = {
      :top_right => "Ability/Mari/beam_cap_tr.png",
      :bottom_right => "Ability/Mari/beam_cap_br.png",
      :bottom_left => "Ability/Mari/beam_cap_bl.png",
      :top_left => "Ability/Mari/beam_cap_tl.png",
      :left => "Ability/Mari/beam_cap_l.png",
      :right => "Ability/Mari/beam_cap_r.png",
      :top => "Ability/Mari/beam_cap_t.png",
      :bottom => "Ability/Mari/beam_cap_b.png",
    }
    beam_end = {
      :bottom_left => "Ability/Mari/beam_cap_tr.png",
      :top_left => "Ability/Mari/beam_cap_br.png",
      :top_right => "Ability/Mari/beam_cap_bl.png",
      :bottom_right => "Ability/Mari/beam_cap_tl.png",
      :right => "Ability/Mari/beam_cap_l.png",
      :left => "Ability/Mari/beam_cap_r.png",
      :bottom => "Ability/Mari/beam_cap_t.png",
      :top => "Ability/Mari/beam_cap_b.png",
    }
    beam_lane ={
      :top_right => "Ability/Mari/beam_up.png",
      :bottom_left => "Ability/Mari/beam_up.png",
      :bottom_right => "Ability/Mari/beam_down.png",
      :top_left => "Ability/Mari/beam_down.png",
      :left => "Ability/Mari/beam_horizontal.png",
      :right => "Ability/Mari/beam_horizontal.png",
      :top => "Ability/Mari/beam_vertical.png",
      :bottom => "Ability/Mari/beam_vertical.png"
    }
    
    # fire in six random directions
    dirs = @current_hex.get_neighbors
    for i in 0..5 do
      # 8 frames between beams
      delay1 += 0.2
      r = rand(dirs.length)
      dir = @current_hex.get_direction_to(dirs[r])
      line = @current_hex.get_line(dir, 4)[0]
      
      # draw the start point on ourself
      corner_spr = new_animation_sprite
      corner_spr.bitmap = RPG::Cache.icon(beam_start[dir])
      corner_spr.opacity = 0
      corner_spr.x = @sprite.x
      corner_spr.y = @sprite.y
      corner_spr.z = @sprite.z + z
      z += 1
      # wait until it's our turn to fire
      corner_spr.add_wait(delay1*fps+delay2)
      # become visible
      corner_spr.add_fade_to(200, 1)
      # slowly fade away
      corner_spr.add_fade_to(0, 3*fps)
      # and dispose
      corner_spr.add_dispose()
      
      # lay down the beam sprites along the line
      for j in 1..line.length-2
        # delay a frame to give an illusion of movement
        delay2 += 1
        beam_spr = new_animation_sprite
        beam_spr.bitmap = RPG::Cache.icon(beam_lane[dir])
        beam_spr.opacity = 0
        beam_spr.x = line[j].pixel_x
        beam_spr.y = line[j].pixel_y
        beam_spr.z = @sprite.z + z
        z += 1
        # wait until it's our turn to fire
        beam_spr.add_wait(delay1*fps+delay2)
        # become visible
        beam_spr.add_fade_to(200, 1)
        # deal damage
        beam_spr.add_damage(Damage_Ability.new(self, [], abil_damage), "enemy")
        # slowly fade away
        beam_spr.add_fade_to(0, 3*fps)
        # and dispose
        beam_spr.add_dispose()
      end
      
      # draw the cap on the final hex
      delay2 += 1
      corner_spr_2 = new_animation_sprite
      corner_spr_2.bitmap = RPG::Cache.icon(beam_end[dir])
      corner_spr_2.opacity = 0
      corner_spr_2.x = line.last().pixel_x
      corner_spr_2.y = line.last().pixel_y
      corner_spr_2.z = @sprite.z + z
      z += 1
      # wait until it's our turn to fire
      corner_spr_2.add_wait(delay1*fps+delay2)
      # become visible
      corner_spr_2.add_fade_to(200, 1)
      # deal damage
      corner_spr_2.add_damage(Damage_Ability.new(self, [], abil_damage), "enemy")
      # slowly fade away
      corner_spr_2.add_fade_to(0, 3*fps)
      # and dispose
      corner_spr_2.add_dispose()
    end
    
    # make Mari glow for the duration
    glow_spr = new_animation_sprite
    glow_spr.bitmap = RPG::Cache.icon("Ability/Hexes/light.png")
    glow_spr.x = @sprite.x
    glow_spr.y = @sprite.y
    glow_spr.z = @sprite.z + z
    z += 1
    glow_spr.opacity = 0
    glow_spr.add_fade_to(192, 0.4*fps)
    glow_spr.add_fading(192, 64, 0.4*fps)
    glow_spr.add_wait((delay1+0.4)*fps+delay2, 1)
    glow_spr.add_dispose(1)

    delay1 += 0.4
    imps = [
      Impact.new(:CLOAK, 1),
      Impact.new(:Casting, 1)
    ]
    Buff_Timed.new(self, self, imps, delay1+(delay2/fps), "Ascension")
    
  end
end

register_planeswalker(Mari)