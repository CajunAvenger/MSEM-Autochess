class BuzzardBarrens < Aura
  
  def self.get_base_stats
    return {
      :name => "Buzzard Barrens",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Aerial planeswalkers'",
      "spells cool down faster while",
      "targeted by melee units.",
      "Gain a Helena."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Helena
    give_unit(Helena)
    
    # Apply to existing Aerials
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Aerials
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:AERIAL)
    imps = [
      Impact_Sight.new(:ARCHIVE, 30)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(BuzzardBarrens)