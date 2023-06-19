class Karina < Planeswalker
  attr_accessor :blinked
  def self.get_base_stats
    return {
      :name       => "Karina",
      :display    => "Karina Oblay",
      :cost       => 3,
      :synergy    => [:SISTERS, :SCOUT, :CHRONOMANCER],
      :range      => [2, 2, 2],
      :power      => [35, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [750, 20, 40],
      :pronoun    => "she/her"
    }
  end

  def attack_sprite_file(attack_keys)
    return "Weapon/mspear.png"
  end
  
end

module AbilityLibrary
  
  def ability_script_karina(target_info, mana_cost=@ability_cost)
    for targetHex in target_info[0]
      next unless targetHex.battler
      duration = mana_amp
      # flicker for 1 + 0.5AP seconds
      target = targetHex.battler
      new_sch = target.sprite.add_schedule
      target.sprite.add_fade_to(75, 0.2*fps, new_sch)
      target.sprite.add_wait(fps*(duration-0.4), new_sch)
      target.sprite.add_fade_to(255, 0.2*fps, new_sch)
      efs = []
      efs.push(Impact.new(:CLOAK, 1))
      efs.push(Impact.new(:FLICKER, 1))
      efs.push(Impact.new(:STUN, 1))
      Debuff_Timed.new(self, target, efs, duration, "Flickered")
    end
  end
  
end
register_planeswalker(Karina)