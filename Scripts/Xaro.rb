class Xaro < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Xaro",
      :cost       => 1,
      :synergy    => [:MIRRORWALKER, :WARRIOR],
      :range      => [1, 2, 2],
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
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/rsword.png"
  end
  
end

module AbilityLibrary
  def ability_script_xaro(target_info, mana_cost=@ability_cost)
    multi = 3 * mana_amp
    for h in target_info[0]
      next unless h.battler
      next if h.controller != @owner
      Buff.new(self, h.battler, Impact.new(:MULTI, multi))
    end
  end
end

register_planeswalker(Xaro)