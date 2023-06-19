class RideIntoTheSunset < Aura
  
  def self.get_base_stats
    return {
      :name => "Ride into the Sunset",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Heddwyn and a",
      "Surveryor's Rifle."
    ]
  end
  
  def self.sprite
    return "Dude"
  end

  def extra_init
    
    # Gain a Heddwyn and a Surveyor's Rifle
    give_unit_and(Heddwyn, Artifact_SurveyorsRifle)
    
  end

end

register_aura(RideIntoTheSunset)