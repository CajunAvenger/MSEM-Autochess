class RahitsStudy < Aura
  
  def self.get_base_stats
    return {
      :name => "Rahit's Study",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Artifacts that grant power",
      "or archive grant even more.",
      "",
      "Gain an Rahit with an",
      "Academic's Claymore."
    ]
  end
  
  def self.sprite
    return "Arcanum"
  end
  
  def enchants
    return :impact
  end

  def extra_init
    
    # Gain an Rahit with a Academic's Claymore
    give_walker_with(Rahit, Artifact_AcademicsClaymore)
    
    
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
      for i in artifact.impacts
        listen.subscriber.apply(i)
      end
    end
    gen_subscription_to(@owner, :EquippedTo, artifact_buffer)
  end
  
  def apply(impact)
    return if @enchanting.include?(impact)
    # Artifacts that grant power or archive grant even more
    buffers = [:POWER, :POWER_MULTI, :ARCHIVE, :ARCHIVE_MULTI]
    return unless buffers.include?(impact.id)
    impact.enchant(self, 0, 0.2)
    @enchanting.push(impact)
  end

end

register_aura(RahitsStudy)