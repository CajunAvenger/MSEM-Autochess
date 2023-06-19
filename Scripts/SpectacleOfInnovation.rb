class SpectacleOfInnovation < Aura
  
  def self.get_base_stats
    return {
      :name => "Spectacle of Innovation",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "All your planeswalkers",
      "gain power and ward for each",
      "Artificer you have with a",
      "completed artifact equipped.",
      "Gain a Volta."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Volta
    give_unit(Volta)
    
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
      Impact_Spectacle.new(:POWER, 10),
      Impact_Spectacle.new(:WARD, 10)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(SpectacleOfInnovation)