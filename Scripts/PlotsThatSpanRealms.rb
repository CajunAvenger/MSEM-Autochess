class PlotsThatSpanRealms < Aura

  def self.get_base_stats
    return {
      :name => "Plots That Span Realms",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Saia and a",
      "two-star Eve.",
      "Your Saias and Eves get",
      "bonus archive as long as",
      "you're deploying both."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init
    
    give_unit(Saia)
    give_unit(Eve, 2)
    
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future plotters
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    friend = {
      "Saia" => "Eve",
      "Eve" => "Saia"
    }
    imp = Impact_DeployedFriend.new(:ARCHIVE, 30, friend[unit.name])
    Buff_Eternal.new(self, unit, imp)
    @enchanting.push(unit)
  end

end

register_aura(PlotsThatSpanRealms)