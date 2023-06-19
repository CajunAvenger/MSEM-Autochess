class LightningDraw < Aura
  
  def self.get_base_stats
    return {
      :name => "Lightning Draw",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Gunslingers' empowered",
      "attacks chain to",
      "nearby enemies.",
      "Gain a Heddwyn."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain a Heddwyn
    give_unit(Heddwyn)
    
    # Set up listener to apply to chain key
    # Unit AI will apply the chain proc
    chainer = Proc.new do |listen, unit, attack_keys|
      next unless unit.synergies.include?(:GUNSLINGER)
      attack_keys[:chain_six] = true
    end
    gen_subscription_to(@owner, :Attacking, chainer)
  end

end

register_aura(LightningDraw)