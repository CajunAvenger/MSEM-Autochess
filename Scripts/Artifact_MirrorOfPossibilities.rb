class Artifact_MirrorOfPossibilities < Artifact
  def self.get_base_stats
    return {
      :name       => "Mirror of Possibilities",
      :description => "Grants 100% multistrike.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:MULTI, 100]]
      ],
      :back   => [:UNIQUE]
    }
  end
  
  def self.get_description
    return [ "Grants 100% multistrike."]
  end
  
end
register_artifact(Artifact_MirrorOfPossibilities)