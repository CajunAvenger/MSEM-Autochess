class InfluenceOfProgenitus < Aura
  
  def self.get_base_stats
    return {
      :name => "InfluenceOfProgenitus",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain an Ajani and a",
      "Terraformer's Globe."
    ]
  end
  
  def self.sprite
    return "Dude"
  end

  def extra_init
    
    # Gain an Ajani and a Terraformer's Globe
    give_unit_and(Ajani, Artifact_TerraformersGlobe)
    
  end

end

register_aura(InfluenceOfProgenitus)