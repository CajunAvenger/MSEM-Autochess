class TheFrontierBeckons < Aura
  
  def self.get_base_stats
    return {
      :name => "The Frontier Beckons",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Kati and a",
      "Ranger's Bow."
    ]
  end
  
  def self.sprite
    return "Dudette"
  end

  def extra_init
    
    # Gain a Kati and a Ranger's Bow
    give_unit_and(Kati, Artifact_RangersBow)
    
  end

end

register_aura(TheFrontierBeckons)