class Artifact_HallowedFragment < Artifact

  def self.get_base_stats
    return {
      :name       => "Hallowed Fragment",
      :description => "Grants mana amp and max life. Also grants life steal " +
        "on spell damage.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:MANA_AMP, 10]],
        [Impact, [:MAX_LIFE, 10]],
        [Impact, [:LIFESTEAL_SPELL, 0.2]]
      ],
      :components => ["Iron Signet", "Spirit Pendant"],
      :back   => [:MANA_AMP, :MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants mana amp and max life.",
      "Also grants life steal on spell",
      "damage."
    ]
  end
  
end

register_artifact(Artifact_HallowedFragment)