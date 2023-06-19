class BeckonDarkness < Aura
  
  def self.get_base_stats
    return {
      :name => "Beckon Darkness",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Necromancers' spells",
      "ignore 80% of ward.",
      "Gain a Rain Zai."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain an Rain
    give_unit(Rain)
    
    # Apply to existing Necromancers
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Necromancers
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:NECROMANCER)
    imps = [
      Impact.new(:WARD_UNMULTI, 0.8),
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(BeckonDarkness)