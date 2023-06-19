class LostInTheRoses < Aura

  def self.get_base_stats
    return {
      :name => "Lost in the Roses",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Replace your Alexas' first",
      "spellcast each combat with",
      "summoning an Elemental token",
      "with stats scaling",
      "with her mana amp.",
      "Gain a two-star Alexa."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init
    
    give_unit(Alexa, 2)
    
    # Apply to existing Alexas
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Alexas
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)

  end
  
  def apply(unit)
    return unless unit.name == "Alexa"
    return if unit.empowered.include?(:LostInTheRoses)
    unit.empowered.push(:LostInTheRoses)
  end

end

register_aura(LostInTheRoses)