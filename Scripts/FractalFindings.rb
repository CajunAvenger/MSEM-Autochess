class FractalFindings < Aura
  
  def self.get_base_stats
    return {
      :name => "Fractal Findings",
      :tier  => 2
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Investigator.",
      "",
      "Gain a Bahum with a",
      "Giltwork Legacy."
    ]
  end
  
  def self.sprite
    return "Investigator"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Bahum with a Giltwork Legacy and an Investigator emblem
    give_unit_with(Bahum, Artifact_GiltworkLegacy)
    
    @owner.synergy_handlers[:INVESTIGATOR].extra_counter += 1
    
  end

end

register_aura(FractalFindings)