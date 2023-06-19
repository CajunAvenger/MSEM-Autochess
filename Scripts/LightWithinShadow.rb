class LightWithinShadow < Aura
  
  def self.get_base_stats
    return {
      :name => "Light Within Shadow",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your planeswalkers deal",
      "damage to nearby enemies",
      "when they gain life.",
      "Gain a Hallowed Fragment."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    @owner.give_artifact(Artifact_HallowedFragment.new)
    
    futureproof = Proc.new do |listen, unit, amount|
      next unless unit.is_a?(Planeswalker)
      tags = []
      for n in unit.current_hex.get_neighbors
        next unless n.battler
        next if n.battler.owner == listen.host
        tags.push(n.battler)
      end
      Damage.new(unit, tags, 0.2*amount).resolve
    end
    gen_subscription_to(@owner, :GainedLife, futureproof)

  end

end

register_aura(LightWithinShadow)