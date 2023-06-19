class Siraj < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Siraj",
      :cost       => 3,
      :synergy    => [:ARTIFICER, :ROGUE, :AKIEVA],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "he/they"
    }
  end
  
  def self.ability_aim
    return [:aggro, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
end

module AbilityLibrary
  def ability_script_siraj(target_info, mana_cost=@ability_cost)
    # Make a melee attack with mana-scaling damage,
    # then steal a % of the target's stats from items for a short duration.
    swipe = Proc.new do |target, amount|
      stats = {
        :POWER => 0,
        :MULTI => 0,
        :HASTE => 0,
        :MANA_AMP => 0,
        :ARCHIVE => 0,
        :TOUGHNESS => 0,
        :WARD => 0,
        :MAX_LIFE => 0,
        :POWER_MULTI => 0,
        :MULTI_MULTI => 0,
        :HASTE_MULTI => 0,
        :MANA_AMP_MULTI => 0,
        :ARCHIVE_MULTI => 0,
        :TOUGHNESS_MULTI => 0,
        :WARD_MULTI => 0,
        :MAX_LIFE_MULTI => 0
      }
      my_imps = []
      yr_imps = []
      for s, val in stats
        next unless target.impacts.include?(s)
        for i in target.impacts[s]
          next unless i.source.is_a?(Artifact)
          stats[s] += i.get_value()
        end
        my_imps.push(Impact.new(s, stats[s]/2))
        yr_imps.push(Impact.new(s, -stats[s]/2))
      end
      Buff_Timed.new(self, self, my_imps, 5, "Pretty Penny")
      Debuff_Timed.new(self, target, yr_imps, 5, "Penny Dreadful")
    end
    no_swiping = Proc.new do |listen, attack_keys|
      attack_keys[:procs].push(swipe)
      attack_keys[:multi_roll] = 1000
      attack_keys[:siraj] = true
    end
    l = gen_subscription_to(self, :Attacking, no_swiping)
    l.fragile = true
    try_attack(false)
  end
end

register_planeswalker(Siraj)
