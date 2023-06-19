class Salva < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Salva",
      :display    => "Salva Tore",
      :cost       => 4,
      :synergy    => [:ARCANUM, :ROGUE],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [650, 20, 40],
      :pronoun    => "they/hem"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/blsword.png"
  end
  
end
#Next attack adds bonus damage equal to a mana-scaling % of the target's max health.
module AbilityLibrary
  def ability_script_salva(target_info, mana_cost=@ability_cost)
    bonus = 0.2 * mana_amp
    execute = Proc.new do |listen, attack_keys|
      ml = attack_keys[:aggro].get_value(:MAX_LIFE)
      attack_keys[:extra_p] += bonus * ml
      attack_keys[:salva] = true
    end
    l = gen_subscription_to(self, :Attacking, execute)
    l.fragile = true
  end
end

register_planeswalker(Salva)