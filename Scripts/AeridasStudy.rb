class AeridasStudy < Aura
  
  def self.get_base_stats
    return {
      :name => "Aerida's Study",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Artifacts that grant haste",
      "or archive grant even more.",
      "",
      "Gain an Aerida with a",
      "Himitsu, Shigure's Legacy."
    ]
  end
  
  def self.sprite
    return "Arcanum"
  end
  
  def enchants
    return :impact
  end

  def extra_init
    
    # Gain an Aerida with a Himitsu
    give_walker_with(Aerida, Artifact_HimitsuShiguresLegacy)
    
    # apply to all existing artifacts
    for id, u in @owner.units
      for a in u.artifacts
        for i in a.impacts
          apply(i)
        end
      end
    end
    
    # set up listeners to affect future artifacts
    artifact_buffer = Proc.new do |listen, artifact, unit|
      console.log(artifact.to_s)
      for i in artifact.impacts
        listen.subscriber.apply(i)
      end
    end
    gen_subscription_to(@owner, :EquippedTo, artifact_buffer)
  end
  
  def apply(impact)
    return if @enchanting.include?(impact)
    # Artifacts that grant haste or archive grant even more
    buffers = [:HASTE, :HASTE_MULTI, :ARCHIVE, :ARCHIVE_MULTI]
    return unless buffers.include?(impact.id)
    impact.enchant(self, 0, 0.2)
    @enchanting.push(impact)
  end

end

register_aura(AeridasStudy)