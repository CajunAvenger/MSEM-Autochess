class Brutality < Aura

  def self.get_base_stats
    return {
      :name => "Brutality",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Bessies gain more",
      "stats from eating enemies.",
      "Gain a Bessie."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init
    
    give_unit(Bessie)
    
    # Apply to existing Bessies
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Bessies
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)

  end
  
  def apply(unit)
    return unless unit.name == "Bessie"
    return if unit.empowered.include?(:Brutality)
    unit.empowered.push(:Brutality)
  end

end

register_aura(Brutality)