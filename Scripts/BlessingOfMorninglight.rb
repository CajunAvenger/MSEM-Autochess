class BlessingOfMorninglight < Aura
  
  def self.get_base_stats
    return {
      :name => "Blessing of Morninglight",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Morninglight units gain",
      "bonus life, scaling with the",
      "number of auras you have.",
      "Gain an Alia."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    
    # Gain an Alia
    give_unit(Alia)
    
    # Apply to existing Morninglights
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Morninglights
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:MORNINGLIGHT)
    imp = Impact_Aura.new(:MAX_LIFE, 40)
    Buff_Eternal.new(self, unit, imp)
    @enchanting.push(unit)
  end

end

register_aura(BlessingOfMorninglight)