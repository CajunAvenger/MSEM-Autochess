class UncoveredSecrets < Aura
  
  def self.get_base_stats
    return {
      :name => "Uncovered Secrets",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain your choice of",
      "one of three random",
      "completed artifacts.",
      "It grants bonus archive."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    targs = []
    for i in 1..3
      targs.push($artifacts[:completed].sample)
    end
    $artifact_scene = ArtifactScene.new(targs, :uncovered)
  end

end
register_aura(UncoveredSecrets)