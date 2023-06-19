class GoldenTouch < Aura
  
  def self.get_base_stats
    return {
      :name => "Golden Touch",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Alara planeswalkers",
      "gain bonus power and",
      "lifesteal or each Alara",
      "unit you have.",
      "Gain a Helene."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Helene
    give_unit(Helene)
    
    # Apply to existing Alaras
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Alaras
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:ALARA)
    imps = [
      Impact_DeployedSyn.new(:LIFESTEAL, 0.05, :ALARA),
      Impact_DeployedSyn.new(:POWER, 10, :ALARA)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(GoldenTouch)