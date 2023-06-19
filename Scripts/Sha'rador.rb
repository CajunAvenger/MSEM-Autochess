class Sharador < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Sharador",
      :display    => "Sha'rador",
      :cost       => 3,
      :synergy    => [:MIRRORWALKER, :COMMANDER],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "they/him"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
  def attack_sprite_file(attack_keys)
    file = "Weapon/Sha/scythe"
    if attack_keys[:aggro].current_hex.pixel_x > @current_hex.pixel_x
      return file + "_r.png"
    end
    return file + "_l.png"
  end
  
end

module AbilityLibrary
  def ability_script_sharador(target_info, mana_cost=@ability_cost)
    sh = 100 * mana_amp
    Buff.new(self, self, Shield.new(sh))
    for u in @owner.deployed
      next if u.is_a?(Planeswalker) && !@temp
      Buff.new(self, u, Shield.new(sh))
    end
  end
end

register_planeswalker(Sharador)
