class Artifact_WardedTome < Artifact
  
  def self.get_base_stats
    return {
      :name   => "Warded Tome",
      :description => "Reduces spell cooldown.",
      :cost   => 1,
      :type   => :component,
      :keys   => ["Book"],
      :impacts => [[Impact, [:ARCHIVE, 10]]],
      :back   => [:ARCHIVE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants +10 archive."
    ]
  end

end

register_artifact(Artifact_WardedTome)