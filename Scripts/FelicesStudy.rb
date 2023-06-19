class FelicesStudy < Aura
  
  def self.get_base_stats
    return {
      :name => "Felice's Study",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Artifacts that grant ward",
      "or archive grant even more.",
      "",
      "Gain an Felice with a Helm,",
      "of Princes."
    ]
  end
  
  def self.sprite
    return "Arcanum"
  end
  
  def enchants
    return :impact
  end

  def extra_init
    
    # Gain an Felice with a Helm of Princes
    give_walker_with(Felice, Artifact_HelmOfPrinces)
    
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
        console.log(i)
        listen.subscriber.apply(i)
      end
    end
    gen_subscription_to(@owner, :EquippedTo, artifact_buffer)
  end
  
  def apply(impact)
    return if @enchanting.include?(impact)
    # Artifacts that grant ward or archive grant even more
    buffers = [:WARD, :WARD_MULTI, :ARCHIVE, :ARCHIVE_MULTI]
    return unless buffers.include?(impact.id)
    impact.enchant(self, 0, 0.2)
    @enchanting.push(impact)
  end

end

register_aura(FelicesStudy)