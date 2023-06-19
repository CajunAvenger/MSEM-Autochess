class Artifact_MageweaveCloak < Artifact
  
  def self.get_base_stats
    return {
      :name   => "Mageweave Cloak",
      :description => "Delays spells that would target the bearer.",
      :cost   => 1,
      :type   => :component,
      :keys   => ["Armor"],
      :impacts => [[Impact, [:WARD, 10]]],
      :back   => [:WARD]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants +10 ward."
    ]
  end

end

register_artifact(Artifact_MageweaveCloak)