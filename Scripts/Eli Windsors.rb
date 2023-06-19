class Eli < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Eli",
      :display    => "Eli Windsors",
      :cost       => 2,
      :synergy    => [:GUNSLINGER, :ASSASSIN],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:aggro, 4]
  end
  
  def self.ability_area
    return [:line, 4]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/Eli/bullet.png"
  end
  
  def six_sprite_file(attack_keys)
    return "Weapon/Eli/six.png"
  end
  
end

module AbilityLibrary
  def ability_script_eli(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    angler = {
      :top => ["l", -5, 90],
      :bottom => ["r", 5, 90],
      :right => ["r", 5, 0],
      :left => ["l", -5, 0],
      :top_right => ["r", 5, 55],
      :top_left => ["l", -5, -55],
      :bottom_right => ["r", 5, -55],
      :bottom_left => ["l", -5, 55]
    }
    dir = angler[target_info[3]][0]
    recoil = angler[target_info[3]][1]
    start_angle = angler[target_info[3]][2]
    
    targs = []
    for h in target_info[0]
      next unless h.battler
      next if h.controller == @owner
      targs.push(h.battler)
    end
    abil_damage = 50 * mana_amp
    r = rand(100) #can multistrike
    rifle = new_animation_sprite
    rifle.bitmap = RPG::Cache.icon("Weapon/Eli/rifle_"+dir+".png")
    rifle.center_on(@sprite)
    rifle.z = @sprite.z + 35
    rifle.angle = start_angle
    rifle.add_wait(0.2*fps)
    rifle.add_damage(Damage_Ability.new(self, targs, abil_damage), "locked")
    rifle.add_spin(recoil, 0.3*fps)
    if r < get_value(:MULTI)
      rifle.add_spin(-recoil, 0.3*fps)
      rifle.add_damage(Damage_Ability.new(self, targs, abil_damage), "locked")
      rifle.add_spin(recoil, 0.3*fps)
    end    
    rifle.add_dispose
  end
  
end

register_planeswalker(Eli)