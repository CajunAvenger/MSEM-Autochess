class Artifact_BurnishedPlate < Artifact
  
  def self.get_base_stats
    return {
      :name   => "Burnished Plate",
      :description => "Reduces incoming basic attack damage.",
      :cost   => 1,
      :type   => :component,
      :keys   => ["Armor"],
      :impacts => [[Impact, [:TOUGHNESS, 10]]],
      :back   => [:TOUGHNESS]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants +10 toughness."
    ]
  end

end

register_artifact(Artifact_BurnishedPlate)