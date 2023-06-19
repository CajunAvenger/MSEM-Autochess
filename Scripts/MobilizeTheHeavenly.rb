class MobilizeTheHeavenly < Aura
  
  def self.get_base_stats
    return {
      :name => "Mobilize the Heavenly",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Helena and a",
      "Tricked-Out Hoverboard."
    ]
  end
  
  def self.sprite
    return "Dudette"
  end

  def extra_init
    
    # Gain a Helena and a Tricked-Out Hoverboard
    give_unit_and(Helena, Artifact_TrickedOutHoverboard)
    
  end

end

register_aura(MobilizeTheHeavenly)