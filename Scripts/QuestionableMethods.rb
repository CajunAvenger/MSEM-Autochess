class QuestionableMethods < Aura
  
  def self.get_base_stats
    return {
      :name => "Questionable Methods",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Investigators gain",
      "bonus power proportional to",
      "how charged their spell is.",
      "Gain a Heddwyn."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain an Heddwyn
    give_unit(Heddwyn)
    
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
      Impact_Mana.new(:POWER, 50)
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(QuestionableMethods)