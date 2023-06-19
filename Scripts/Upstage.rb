class Upstage < Aura
  
  def self.get_base_stats
    return {
      :name => "Upstage",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Thespians gain large",
      "amounts of bonus power and",
      "mana amp while cloaked.",
      "Gain a Lucien."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Lucien
    give_unit(Lucien)
    
    # Apply to existing Thespians
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Thespians
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:THESPIAN)
    imps = [
      Impact_KeyPercent.new(:POWER, 60, unit, :CLOAK),
      Impact_KeyPercent.new(:MANA_AMP, 60, unit, :CLOAK)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(Upstage)