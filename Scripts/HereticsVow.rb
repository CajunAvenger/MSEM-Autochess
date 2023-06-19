class HereticsVow < Aura
  
  def self.get_base_stats
    return {
      :name => "Heretic's Vow",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Clerics have lifesteal and",
      "gain increasing amounts of",
      "power as combat goes on.",
      "Gain a Bahum."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Bahum
    give_unit(Bahum)
    
    # Apply to existing Clerics
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Clerics
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:CLERIC)
    imps = [
      Impact.new(:LIFESTEAL, 0.1),
      Impact_Combat.new(:POWER, 50)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(HereticsVow)