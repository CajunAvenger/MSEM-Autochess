class RiteOfLostTimelines < Aura
  
  def self.get_base_stats
    return {
      :name => "Rite of Lost Timelines",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Investigators double",
      "their archive bonus, and do",
      "extra damage after winning,",
      "but have reduced max life.",
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
    # Gain an Bahum
    give_unit(Bahum)
    
    # Apply to existing Investigators
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Investigators
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
    
  end

  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:INVESTIGATOR)
    imps = [
      Impact.new(:MAX_LIFE_MULTI, -0.2)
    ]
    Buff_Eternal.new(self, unit, imps)
    unit.bonus_loss_damage += 4
    @enchanting.push(unit)
  end

end

register_aura(RiteOfLostTimelines)