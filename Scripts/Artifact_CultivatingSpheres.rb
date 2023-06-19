class Artifact_CultivatingSpheres < Artifact
  def self.get_base_stats
    return {
      :name       => "Cultivating Spheres",
      :description => "Grants huge amount of archive, and increasing mana " + 
          "amp as combat goes on.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:ARCHIVE, 100]],
        [Impact_Combat, [:MANA_AMP, 200]]
        ],
      :back   => [:UNIQUE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants huge amount of archive",
      "and increasing mana amp as",
      "combat goes on."
    ]
  end
end
register_artifact(Artifact_CultivatingSpheres)