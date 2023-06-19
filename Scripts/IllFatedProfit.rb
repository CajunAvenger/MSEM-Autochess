class IllFatedProfit < Aura
  
  def self.get_base_stats
    return {
      :name => "Ill-Fated Profit",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your interest cap is greatly",
      "increased, but your planeswalkers",
      "have reduced max life proportional",
      "to your gold reserves."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end

  def extra_init
    
    @owner.interest_cap += 5 unless @owner.interest_cap == 0

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
    imp = Impact_Hoard.new(:MAX_LIFE_MULTI, -1)
    Buff_Eternal.new(self, unit, imp)
    @enchanting.push(unit)
  end

end

register_aura(IllFatedProfit)