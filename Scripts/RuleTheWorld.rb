class RuleTheWorld < Aura
  
  def self.get_base_stats
    return {
      :name => "Rule the World",
      :tier  => 3
    }
  end
  
  def self.get_description
    return [
      "Gain an Ambition's Crown."
    ]
  end
  
  def self.sprite
    return "Skypath"
  end

  def extra_init
    
    # Gain an Ambition's Crown
    @owner.give_artifact(Artifact_AmbitionsCrown.new)
    
  end

end

register_aura(RuleTheWorld)