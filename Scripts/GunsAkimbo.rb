class GunsAkimbo < Aura
  
  def self.get_base_stats
    return {
      :name => "Guns Akimbo",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Gunslingers gain",
      "multistrike chance.",
      "Gain an Eli."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain an Eli
    give_unit(Eli)
    
    # Apply to existing Gunslingers
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Gunslingers
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:GUNSLINGER)
    imps = [
      Impact.new(:MULTI, 10)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(GunsAkimbo)