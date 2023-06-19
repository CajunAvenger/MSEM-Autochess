class Artifact_ExpertBelt < Artifact

  def self.get_base_stats
    return {
      :name       => "Expert Belt",
      :description => "Grants power and ward. Grants even more if bearer " +
        "start combat with no adjacent allies.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Belt"],
      :impacts    => [
        [Impact, [:POWER, 10]],
        [Impact_LonelyStart, [:POWER, 50]],
        [Impact, [:WARD, 10]],
        [Impact_LonelyStart, [:WARD, 50]]
      ],
      :components => ["Seishin's Edge", "Mageweave Cloak"],
      :back   => [:POWER, :WARD]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants power and ward. Grants",
      "even more if bearer start combat",
      "with no adjacent allies.",
    ]
  end
  
end

register_artifact(Artifact_ExpertBelt)