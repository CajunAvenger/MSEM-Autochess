class TheClocktowerProject < Aura
  
  def self.get_base_stats
    return {
      :name => "The Clocktower Project",
      :tier  => 2
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Chronomancer.",
      "",
      "Gain a Volta with a Hub",
      "of Innovation"
    ]
  end
  
  def self.sprite
    return "Chronomancer"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Volta with a Hub of Innovation and a Chronomancer emblem
    give_unit_with(Volta, Artifact_HubOfInnovation)
    
    @owner.synergy_handlers[:CHRONOMANCER].extra_counter += 1
    
  end

end

register_aura(TheClocktowerProject)