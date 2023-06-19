class WitchsInvocation < Aura
  
  def self.get_base_stats
    return {
      :name => "Witch's Invocation",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain an Arina and an",
      "Isochron Wand."
    ]
  end
  
  def self.sprite
    return "Dudette"
  end

  def extra_init
    
    # Gain an Arina and an Isochron Wand
    give_unit_and(Arina, Artifact_IsochronWand)
    
  end

end

register_aura(WitchsInvocation)