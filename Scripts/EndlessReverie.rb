class EndlessReverie < Aura
  
  def self.get_base_stats
    return {
      :name => "Endless Reverie",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Mirrorwalkers heal",
      "when any of your units die.",
      "Gain a Sha'rador."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Sharador
    give_unit(Sharador)
    
    # Apply to existing Mirrorwalkers
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Mirrorwalkers
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:MIRRORWALKER)
    heal = Proc.new do |listen, *args|
      listen.subscriber.apply_heal(Heal.new(100))
    end
    unit.gen_subscription_to(@owner, :Died, heal)
    @enchanting.push(unit)
  end

end

register_aura(EndlessReverie)