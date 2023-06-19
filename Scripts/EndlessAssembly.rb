class EndlessAssembly < Aura
  
  def self.get_base_stats
    return {
      :name => "Endless Assembly",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Artificers gain haste",
      "for each component they",
      "have equipped, and more",
      "for every completed item.",
      "Gain a Siraj."
    ]
  end

  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Siraj
    give_unit(Siraj)
    
    # Apply to existing Artificers
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Artificers
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)

  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:ARTIFICER)
    imps = [
      Impact_Warhammer.new(:HASTE_MULTI, 0.1, 1, 2)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(EndlessAssembly)