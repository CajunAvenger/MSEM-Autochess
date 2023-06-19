class Artifact_AtlasOfWorlds < Artifact

  def self.get_base_stats
    return {
      :name       => "Atlas of Worlds",
      :description => "Grants large amounts of archive.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Book"],
      :impacts    => [
        [Impact, [:ARCHIVE, 20]],
        [Impact, [:ARCHIVE_MULTI, 0.2]]
      ],
      :back   => [:UNIQUE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants large amounts of archive."
    ]
  end
  
end

register_artifact(Artifact_AtlasOfWorlds)