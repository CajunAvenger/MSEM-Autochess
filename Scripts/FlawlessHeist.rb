class FlawlessHeist < Aura
  
  def self.get_base_stats
    return {
      :name => "Flawless Heist",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Choose one of",
      "five rare artifacts."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    targs = [
      Artifact_TomeOfLoss,
      Artifact_AmuletOfLoyalties,
      Artifact_EldritchEgg,
      Artifact_Awestone,
      Artifact_AtlasOfWorlds
    ]
    $artifact_scene = ArtifactScene.new(targs)
  end

end
register_aura(FlawlessHeist)