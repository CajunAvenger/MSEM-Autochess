class OraclesPloy < Aura
  
  def self.get_base_stats
    return {
      :name => "Oracle's Ploy",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Know which enemy you'll",
      "fight next each round.",
      "Gain a Needle Doll."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    @owner.give_artifact(Artifact_NeedleDoll.new)
    @owner.empowered.push(:foresight)

  end

end

register_aura(OraclesPloy)