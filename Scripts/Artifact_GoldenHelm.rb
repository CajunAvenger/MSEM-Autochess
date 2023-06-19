class Artifact_GoldenHelm < Artifact

  def self.get_base_stats
    return {
      :name       => "Golden Helm",
      :description => "Grants mana amp and toughness. Increases mana amp " +
        "even more for each enemy targeting the wielder.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Armor"],
      :impacts    => [
        [Impact, [:MANA_AMP, 10]],
        [Impact, [:TOUGHNESS, 10]],
        [Impact_Sights, [:MANA_AMP, 10]]
      ],
      :components => ["Iron Signet", "Burnished Plate"],
      :back   => [:MANA_AMP, :TOUGHNESS]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants mana amp and toughness.",
      "Increases mana amp even more for",
      "each enemy targeting the wielder."
    ]
  end
  
end

register_artifact(Artifact_GoldenHelm)