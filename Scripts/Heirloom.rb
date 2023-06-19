class Heirloom < Aura
  
  def self.get_base_stats
    return {
      :name => "Heirloom",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain your choice of",
      "one of four random",
      "completed artifacts."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    targs = []
    for i in 1..4
      targs.push($artifacts[:completed].sample)
    end
    $artifact_scene = ArtifactScene.new(targs)
  end

end
register_aura(Heirloom)