class SuccumbToDreams < Aura
  
  def self.get_base_stats
    return {
      :name => "Succumb to Dreams",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Helm of Princes.",
      "Your Helms of Princes also",
      "grant mana amp whenever",
      "its bearer delays a spell."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    @owner.give_artifact(Artifact_HelmOfPrinces.new)
    for id, u in @owner.units
      for a in u.artifacts
        next unless a.name == "Helm of Princes"
        a.dream_up
      end
    end
    
    ref = Proc.new do |listen, artifact, *args|
      next unless artifact.name == "Helm of Princes"
      artifact.dream_up
    end
    gen_subscription_to(@owner, :EquippedTo, ref)
  end

end

register_aura(SuccumbToDreams)