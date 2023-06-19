class Felice < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Felice",
      :cost       => 3,
      :synergy    => [:ARCANUM, :ELDER, :WIZARD],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [40, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [950, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:aggro, 2]
  end
  
  def self.ability_area
    return [:cone, 3]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/wray.png"
  end
  
end

module AbilityLibrary
  def ability_script_felice(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    angler = {
      :top => 180,
      :bottom => 0,
      :left => -90,
      :right => 90,
      :top_right => 135,
      :top_left => -135,
      :bottom_left => -45,
      :bottom_right => 45
    }
    angle = to_radians(angler[target_info[3]])

    run = 0.55*fps
    face = new_animation_sprite
    face.bitmap = RPG::Cache.icon("Ability/Chronomancer/clock.png")
    face.ox = face.center_x
    face.oy = face.center_y
    face.y = @sprite.midpoint_y + 80*Math.cos(angle)
    face.x = @sprite.midpoint_x + 80*Math.sin(angle)
    face.z = @sprite.z+30
    face.add_wait(run)
    face.add_change_bitmap(RPG::Cache.icon("Ability/Chronomancer/clock_inv.png"))
    face.add_wait(0.25*fps)
    face.add_dispose

    minute = new_animation_sprite
    minute.bitmap = RPG::Cache.icon("Ability/Chronomancer/minute.png")
    minute.ox = minute.center_x
    minute.oy = minute.center_y
    minute.y = @sprite.midpoint_y + 80*Math.cos(angle)
    minute.x = @sprite.midpoint_x + 80*Math.sin(angle)
    minute.z = @sprite.z+32
    minute.add_spin(-18, run)
    minute.add_change_bitmap(RPG::Cache.icon("Ability/Chronomancer/minute_inv.png"))
    minute.add_spin(18, 0.25*fps)
    minute.add_dispose

    hour = new_animation_sprite
    hour.bitmap = RPG::Cache.icon("Ability/Chronomancer/hour.png")
    hour.ox = minute.center_x
    hour.oy = minute.center_y
    hour.y = @sprite.midpoint_y + 80*Math.cos(angle)
    hour.x = @sprite.midpoint_x + 80*Math.sin(angle)
    hour.z = @sprite.z+31
    hour.add_spin(-1, run)
    hour.add_change_bitmap(RPG::Cache.icon("Ability/Chronomancer/hour_inv.png"))
    hour.add_wait(0.25*fps)
    hour.add_dispose

    boom = Proc.new do |frames|
      blinkers = []
      for h in target_info[0]
        next unless h.battler
        next if h.controller == @owner
        blinkers.push(h.battler)
      end
      Damage_Ability.new(self, blinkers, 100).resolve()
      
      blink = Proc.new do |frames|
        free_hexes = []
        for id, h in @owner.match.board.board_map
          free_hexes.push(h) unless h.battler
        end
        for u in blinkers
          next if u.dead
          break unless free_hexes.length > 0
          r = rand(free_hexes.length)
          free_hexes[r].set_battler(u)
          free_hexes.delete_at(r)
        end
      end
      
      $timer.add_framer(0.25*fps+1, blink)
    end
    $timer.add_framer(run, boom)
    
  end
end

register_planeswalker(Felice)