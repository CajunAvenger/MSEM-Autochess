class Artifact_FlintlockPistol < Artifact
  
  def self.get_base_stats
    return {
      :name   => "Flintlock Pistol",
      :description => "Small chance for basic attacks to trigger multiple times.",
      :cost   => 1,
      :type   => :component,
      :keys   => ["Gun"],
      :impacts => [[Impact, [:MULTI, 10]]],
      :back   => [:MULTI]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants +10% multistrike chance."
    ]
  end

end

register_artifact(Artifact_FlintlockPistol)