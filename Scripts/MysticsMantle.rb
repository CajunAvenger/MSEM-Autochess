class MysticsMantle < Aura
  
  def self.get_base_stats
    return {
      :name => "Mystic's Mantle",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Artifacts that grant ward",
      "also grant bonus archive.",
      "Gain two Mageweave Cloaks."
    ]
  end
  
  def self.sprite
    return "Smith"
  end
  
  def enchants
    return :artifact
  end

  def extra_init
    
    # Gain two Mageweave Cloak
    @owner.give_artifact(Artifact_MageweaveCloak.new)
    @owner.give_artifact(Artifact_MageweaveCloak.new)
    
    # apply to all existing artifacts
    for id, u in @owner.units
      for a in u.artifacts
        apply(a)
      end
    end
    
    # set up listeners to affect future artifacts
    artifact_buffer = Proc.new do |listen, artifact, unit|
      listen.subscriber.apply(artifact)
    end
    gen_subscription_to(@owner, :EquippedTo, artifact_buffer)
  end
  
  def apply(artifact)
    return if @enchanting.include?(artifact)
    # Artifacts that grant ward also grant mana amp
    buffers = [:WARD, :WARD_MULTI]
    valid = false
    for i in artifact.impacts
      next unless buffers.include?(i.id)
      valid = true
      break
    end
    return unless valid
    imp = Impact.new(:ARCHIVE, 20)
    imp.register(artifact, artifact.wielder)
    artifact.impacts.push(imp)
    artifact.wielder.add_impact(imp)
    @enchanting.push(artifact)
  end

end

register_aura(MysticsMantle)