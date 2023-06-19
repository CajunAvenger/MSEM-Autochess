class Artifact_NexusOfPossibilities < Artifact

  def self.get_base_stats
    return {
      :name       => "Nexus of Possibilities",
      :description => "Grants mana amp, and even more to Convergents.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:MANA_AMP, 20]],
        [Impact_SynCheck, [:MANA_AMP, 20, :CONVERGENT]]
      ],
      :components => ["Iron Signet", "Iron Signet"],
      :back   => [:MANA_AMP]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants mana amp, and even more",
      "to Convergent planeswalkers."
    ]
  end
  
end

register_artifact(Artifact_NexusOfPossibilities)