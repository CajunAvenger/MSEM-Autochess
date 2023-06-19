class Xiong < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Xiong",
      :display    => "Xiong Mao",
      :cost       => 2,
      :synergy    => [:WARRIOR, :SCOUT],
      :range      => [3, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :starting_mana => 90,
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/arrow.png"
  end
  
end

module AbilityLibrary
  def ability_script_xiong(target_info, mana_cost=@ability_cost)
    # Make a melee attack with power-scaling damage,
    # then gain a shield for a mana-based % of the damage that got through the target's toughness,
    # then taunt the target.
    for_jund = Proc.new do |target, amount, damage_event|
      per = damage_event.amount.to_f / amount
      Buff.new(self, self, Shield.new(per * mana_amp * 100))
      taunt = Impact.new(:TAUNT, 1, self, self)
      xbuff = Debuff_Timed.new(self, target, taunt, 5)
    end
    slams_fist_on_table = Proc.new do |listen, attack_keys|
      attack_keys[:extra_p] += get_value(:POWER)
      attack_keys[:procs].push(for_jund)
    end
    l = gen_subscription_to(self, :Attacking, slams_fist_on_table)
    l.fragile = true
    try_attack(false)
  end
end

register_planeswalker(Xiong)