class Boxue < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Boxue",
      :display    => "Boxue and Ma'Long",
      :cost       => 2,
      :synergy    => [:DRACONIC, :WIZARD],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [200, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [1450, 20, 40],
      :starting_mana => 60.0,
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:aggro, 4]
  end
  
  def self.ability_area
    return [:custom, 1]
  end
  
  def attack_sprite_file(attack_keys)
    ah = attack_keys[:aggro].current_hex
    if ah.pixel_x < @current_hex.pixel_x
      return "Weapon/rray.png"
    elsif ah.pixel_x > @current_hex.pixel_x
      return "Weapon/uray.png"
    elsif ah.pixel_y < @current_hex.pixel_y
      return "Weapon/rray.png"
    else
      return "Weapon/uray.png"
    end
  end
  
end

module AbilityLibrary
  def ability_script_boxue(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    targets = target_info[0]
    colors = ["r", "u"]
    abil_damage = 100 * mana_amp
    for i in 0..targets.length-1
      target = targets[i].battler
      next unless target
      fireball = new_animation_sprite
      fireball.bitmap = RPG::Cache.icon("Ability/"+colors[i%2]+"meteor.png")
      console.log("self center")
      fireball.center_on(@sprite)
      fireball.angle = angle_of(@sprite, target.sprite)
      fireball.z = @sprite.z + 27
      fireball.add_slide_to(target.sprite, 0.4*fps)
      fireball.add_damage(Damage_Ability.new(self, target, abil_damage), "locked")
      fireball.add_fade_to(0, 0.2*fps)
      fireball.add_dispose
      
      for n in targets[i].get_neighbors
        miniball = new_animation_sprite
        miniball.bitmap = RPG::Cache.icon("Weapon/"+colors[i%2]+"ray.png")
        console.log("center on " + targets[i].id.to_s)
        miniball.center_on(targets[i])
        miniball.z = @sprite.z + 28
        miniball.angle = angle_of(targets[i], n)
        miniball.opacity = 0
        miniball.add_wait(0.4*fps)
        miniball.add_fade_to(255, 1)
        miniball.add_move_to(n.midpoint_x, n.midpoint_y, 0.3*fps)
        miniball.add_damage(Damage_Ability.new(self, nil, 0.5*abil_damage), "enemy")
        miniball.add_fade_to(0, 0.2*fps)
        miniball.add_dispose
      end
    end
  end
  
  def area_script_boxue(targetHex, mana_cost=@ability_cost)
    impact_zone = targetHex.get_area_hexes(2)[0]
    second_target = nil
    
    if @owner.opponent.deployed.length == 1
      # only one target
    elsif @owner.opponent.deployed.length == 2
      # exactly two, just grab the other
      second_target = @owner.opponent.deployed[0].current_hex
      second_target = @owner.opponent.deployed[1].current_hex if second_target == targetHex
    else
      # try to get two at a distance
      backup = []
      for u in @owner.opponent.deployed
        next if u.current_hex == targetHex
        next unless can_target?(u.current_hex)
        if impact_zone.include?(u.current_hex)
          backup.push(u.current_hex)
          next
        end
        second_target = u.current_hex
        break
      end
      if !second_target
        for h in backup
          next if h == targetHex
          second_target = h
          break
        end
      end
    end  
    out = [ [targetHex], [{:dist => 0, :hexes => [targetHex]}] ]
    if second_target
      out = [
        [targetHex, second_target],
        [{:dist => 0, :hexes => [targetHex, second_target]}]
      ]
    end
    return out
  end
end

register_planeswalker(Boxue)
