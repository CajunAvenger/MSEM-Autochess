class LafteriiIngenuity < Aura

  def self.get_base_stats
    return {
      :name => "Lafterii Ingenuity",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Whenever one of your Wizards",
      "casts their spell, each of",
      "your other Wizards gains",
      "mana amp.",
      "Gain a Certo."
    ]
  end

  def self.sprite
    return "Buff"
  end
  
  def extra_init
    # Gain a Certo
    give_unit(Certo)
       
    @buff_map = {}
    
    futureproof = Proc.new do |listen, unit, *args|
      next unless unit.synergies.include?(:WIZARD)
      for u in listen.host.deployed
        next unless unit.synergies.include?(:WIZARD)
        next if u == unit
        test_buff = @buff_map[u.id]
        if test_buff && unit.buffs.include(test_buff.id)
          test_buff.impacts[0].amount += 10
        else
          b = Buff.new(self, u, Impact.new(:MANA_AMP, 10))
          @buff_map[u.id] = b
        end
      end
    end
    gen_subscription_to(@owner, :UsedAbility, futureproof)
  end

end

register_aura(LafteriiIngenuity)