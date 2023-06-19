class PrismaticLeyline < Aura
  
  def self.get_base_stats
    return {
      :name => "Prismatic Leyline",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Arcanum planeswalkers",
      "gain mana amp proportional",
      "to their cost.",
      "Gain a Kati."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Kati
    give_unit(Kati)
    
    # Apply to existing Arcanums
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Arcanums
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)

  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:ARCANUM)
    imps = [
      Impact.new(:MANA_AMP, 20*unit.cost),
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(PrismaticLeyline)