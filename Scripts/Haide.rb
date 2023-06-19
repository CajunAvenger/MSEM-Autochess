class Haide < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Haide",
      :cost       => 4,
      :synergy    => [:GUNSLINGER, :ROGUE],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [950, 20, 40],
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
    return "Weapon/Haide/bullet.png"
  end
  
  def six_sprite_file(attack_keys)
    return "Weapon/Haide/six.png"
  end

end

module AbilityLibrary
  def ability_script_haide(target_info, mana_cost=@ability_cost)
    boom = Proc.new do |listen, attack_keys|
      attack_keys[:extra_p] += 40 * mana_amp
      attack_keys[:haide] = true
    end
    l = gen_subscription_to(self, :Attacking, boom)
    l.fragile = true
  end
end

register_planeswalker(Haide)