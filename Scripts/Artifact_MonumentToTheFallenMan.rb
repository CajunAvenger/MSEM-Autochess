class Artifact_MonumentToTheFallenMan < Artifact

  def self.get_base_stats
    return {
      :name       => "Monument to the Fallen Man",
      :description => "Grants haste. Also cloaked while moving.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:HASTE_MULTI, 0.2]],
        [Impact_Moving, [:CLOAK, 1]]
      ],
      :components => ["Cinderblade", "Cinderblade"],
      :back   => [:HASTE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
     "Grants haste. Also cloaked while",
     "moving."
    ]
  end
  
end

register_artifact(Artifact_MonumentToTheFallenMan)