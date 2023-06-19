class FallbackPlan < Aura
  
  def self.get_base_stats
    return {
      :name => "Fallback Plan",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "After selling a two- or",
      "three-star unit, your next",
      "three store refreshes are free."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end

  def extra_init
    
    @owner.empowered.push(:fallback)

  end

end

register_aura(FallbackPlan)