class Artifact_IronSignet < Artifact
  
  def self.get_base_stats
    return {
      :name   => "Iron Signet",
      :description => "Increases spell effect.",
      :cost   => 1,
      :type   => :component,
      :keys   => ["Trinket"],
      :impacts => [[Impact, [:MANA_AMP, 10]]],
      :back   => [:MANA_AMP]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants +10 mana amp."
    ]
  end

end

register_artifact(Artifact_IronSignet)