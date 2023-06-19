class IntoTheUnknown < Aura
  
  def self.get_base_stats
    return {
      :name => "Into the Unknown",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Each of your Scouts that",
      "starts combat with no adjacent",
      "allies gains bonus power",
      "and toughness.",
      "Gain a Xiong Mao."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain a Xiong
    give_unit(Xiong)
    
    into = Proc.new do |listen|
      for u in listen.host.deployed
        next unless u.synergies.include?(:SCOUT)
        ns = u.current_hex.get_neighbors
        as = 0
        for n in ns
          as += 1 if n.battler && n.battler.owner == listen.host
        end
        next if as > 0
        imps = [
          Impact.new(:POWER, 20),
          Impact.new(:TOUGHNESS, 20)
        ]
        Buff.new(self, u, imps)
      end
    end
    gen_subscription_to(@owner, :Deployed, into)
  end

end

register_aura(IntoTheUnknown)