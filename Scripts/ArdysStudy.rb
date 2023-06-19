class ArdysStudy < Aura
  
  def self.get_base_stats
    return {
      :name => "Ardy's Study",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Artifacts that grant",
      "mana amp or archive",
      "grant even more.",
      "",
      "Gain an Ardy with a",
      "Hub of Innovation."
    ]
  end
  
  def self.sprite
    return "Arcanum"
  end
  
  def enchants
    return :impact
  end

  def extra_init
    
    # Gain an Ardy with a Hub of Innovation
    unit = Ardy.new(@owner)
    give_walker_with(Ardy, Artifact_HubOfInnovation)
    
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
    # Artifacts that grant mana amp or archive grant even more
    buffers = [:MANA_AMP, :MANA_AMP_MULTI, :ARCHIVE, :ARCHIVE_MULTI]
    return unless buffers.include?(impact.id)
    impact.enchant(self, 0, 0.2)
    @enchanting.push(impact)
  end

end

register_aura(ArdysStudy)