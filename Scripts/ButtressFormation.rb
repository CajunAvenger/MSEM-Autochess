class ButtressFormation < Aura
  
  def self.get_base_stats
    return {
      :name => "Buttress Formation",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your units gain bonus power",
      "based on their toughness.",
      "Gain two Burnished Plates."
    ]
  end
  
  def self.sprite
    return "Smith"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    
    @owner.give_artifact(Artifact_BurnishedPlate.new)
    @owner.give_artifact(Artifact_BurnishedPlate.new)
    
    # Apply to existing units
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future units
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)

  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    imps = [
      Impact_KeyPercent.new(:POWER, 0.2, unit, :TOUGHNESS)
    ]
    Buff_Eternal.new(self, unit, imps)
  end

end

register_aura(ButtressFormation)