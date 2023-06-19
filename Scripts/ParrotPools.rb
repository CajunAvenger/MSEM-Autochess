class ParrotPools < Aura
  
  def self.get_base_stats
    return {
      :name => "Parrot Pools",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Aerial planeswalkers",
      "get bonus haste and archive,",
      "scaling with the number of",
      "active synergies you have.",
      "Gain a Flynn."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Flynn
    give_unit(Flynn)
    
    # Apply to existing Aerials
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Aerials
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:AERIAL)
    imps = [
      Impact_SynCounter.new(:HASTE_MULTI, 0.1),
      Impact_SynCounter.new(:ARCHIVE, 10)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(ParrotPools)