class Artifact_AlenianWarhammer < Artifact

  def self.get_base_stats
    return {
      :name       => "Alenian Warhammer",
      :description => "Increases basic attack damage for every equipped component," +
                      " and more for every completed item.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Hammer"],
      :impacts    => [[Impact_Warhammer, [:POWER, 15, 1, 2, 0]]],
      :components => ["Seishin's Edge", "Seishin's Edge"],
      :back   => [:POWER]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Increases basic attack damage for",
      "every equipped component, and",
      "more for every completed item."
    ]
  end
end

register_artifact(Artifact_AlenianWarhammer)