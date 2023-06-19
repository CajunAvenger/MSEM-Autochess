class Artifact_SpiritPendant < Artifact
  
  def self.get_base_stats
    return {
      :name   => "Spirit Pendant",
      :description => "Increases total life points.",
      :cost   => 1,
      :type   => :component,
      :keys   => ["Trinket"],
      :impacts => [[Impact, [:MAX_LIFE, 10]]],
      :back   => [:MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants +10 max life."
    ]
  end
  
end

register_artifact(Artifact_SpiritPendant)