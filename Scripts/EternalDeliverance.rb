class EternalDeliverance < Aura
  
  def self.get_base_stats
    return {
      :name => "Eternal Deliverance",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Cats gain large",
      "amounts of lifesteal when",
      "below half health.",
      "Gain a Mafua."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Mafua
    give_unit(Mafua)
    
    # Apply to existing Cats
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Cats
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:CAT)
    imp = Impact_UnderLife.new(:LIFESTEAL, 0.2, 0.5)
    Buff_Eternal.new(self, unit, imp)
    @enchanting.push(unit)
  end

end

register_aura(EternalDeliverance)