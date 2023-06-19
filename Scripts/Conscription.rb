class Conscription < Aura

  def self.get_base_stats
    return {
      :name => "Conscription",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your soldier tokens gain",
      "increased stats.",
      "Gain a Helena."
    ]
  end

  def self.sprite
    return "Buff"
  end
  
  def extra_init
    # Gain a Helena
    give_unit(Helena)
    
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
    return unless unit.is_a?(Commander_Soldier)
    imps = [
      Impact.new(:MAX_LIFE, 100),
      Impact.new(:POWER, 20),
      Impact.new(:MULTI, 10),
      Impact.new(:HASTE, 0.2),
      Impact.new(:MANA_AMP, 10),
      Impact.new(:ARCHIVE, 10),
      Impact.new(:TOUGHNESS, 10),
      Impact.new(:WARD, 10)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(Conscription)