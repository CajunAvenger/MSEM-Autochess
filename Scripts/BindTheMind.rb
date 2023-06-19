class BindTheMind < Aura

  def self.get_base_stats
    return {
      :name => "Bind the Mind",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "The target of your Meis'",
      "spells charge their spell",
      "half as fast.",
      "Gain two Mei."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init
    
    give_unit(Mei)
    give_unit(Mei)
    
    # Apply to existing Meis
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Meis
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)

  end
  
  def apply(unit)
    return unless unit.name == "Mei"
    return if unit.empowered.include?(:BindTheMind)
    unit.empowered.push(:BindTheMind)
  end

end

register_aura(BindTheMind)