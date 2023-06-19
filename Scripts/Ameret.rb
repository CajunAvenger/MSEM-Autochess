class Ameret < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Ameret",
      :cost       => 1,
      :synergy    => [:AERIAL, :COMMANDER],
      :range      => 1,
      :power      => [65, 100, 145],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 45,
      :ward       => 10,
      :life       => [650, 1170, 2100],
      :ability_cost => 100,
      :starting_mana => 50.0,
      :mana_cooldown => 1.0,
      :slow_start => 0.0,
      :pronoun    => "they/them"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
end

module AbilityLibrary
  def ability_script_ameret(target_info, mana_cost=@ability_cost)
    area = @current_hex.get_area_hexes
    soldiers = [self]
    for h in area[0]
      next unless h.battler
      next unless h.battler.is_a?(Commander_Soldier)
      soldiers.push(h.battler)
    end
    ma = mana_amp
    for s in soldiers
      imps = [
        Impact.new(:HASTE_MULTI, 0.2*ma),
        Impact.new(:TRUE_DAMAGE_ATTACK, 40*ma),
        Impact.new(:LIFESTEAL_ATTACK, 0.2*ma)
      ]
      abuff = Buff.new(self, s, imps)
      abuff.counter = 4
      dec = Proc.new do |listen, attack_keys|
        listen.subscriber.counter -= 1
        if listen.subscriber.counter == 0
          listen.host.mana_cooldown = 0
          listen.subscriber.clear_buff
        end
      end
      abuff.gen_subscription_to(s, :DoneAttacking, dec)
    end
    @mana_cooldown = 100000
  end
end

register_planeswalker(Ameret)