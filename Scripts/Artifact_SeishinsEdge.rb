class Artifact_SeishinsEdge < Artifact
  def self.get_base_stats
    return {
      :name   => "Seishin's Edge",
      :description => "+10 Power",
      :cost   => 1,
      :type   => :component,
      :keys   => ["Sword"],
      :impacts => [[Impact, [:POWER, 10]]],
      :back   => [:POWER]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants +10 power."
    ]
  end


end
register_artifact(Artifact_SeishinsEdge)