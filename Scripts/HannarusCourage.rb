class HannarusCourage < Aura
  
  def self.get_base_stats
    return {
      :name => "Hannaru's Courage",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain Hannaru's",
      "Spear and Aegis."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    @owner.give_artifact(Artifact_Hannarus.new)

  end

end

register_aura(HannarusCourage)