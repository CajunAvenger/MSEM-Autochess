class ReflectedGrandeur < Aura
  
  def self.get_base_stats
    return {
      :name => "Reflected Grandeur",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Shimmerhide Boots.",
      "Whenever any of your Shimmerhide",
      "Boots absorb an attack, they also",
      "grant stacking power and",
      "toughness to the bearer."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    @owner.give_artifact(Artifact_ShimmerhideBoots.new)
    for id, u in @owner.units
      for a in u.artifacts
        apply(a)
      end
    end
    
    ref = Proc.new do |listen, artifact, *args|
      listen.subscriber.apply(artifact)
    end
    gen_subscription_to(@owner, :EquippedTo, ref)
  end
  
  def apply(artifact)
    return if @enchanting.include?(artifact)
    return unless artifact.name == "Shimmerhide Boots"
    artifact.empowered.push(:reflected)
    @enchanting.push(artifact)
  end

end

register_aura(ReflectedGrandeur)