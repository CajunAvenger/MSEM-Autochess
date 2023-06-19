class Artifact_TinkerersTools < Artifact
  
  def self.get_base_stats
    return {
      :name   => "Tinkerer's Tools",
      :description => "Has no effect.",
      :cost   => 1,
      :type   => :component,
      :rare   => true,
      :keys   => ["Trinket"],
      :impacts => [],
      :back   => [:UNIQUE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Has no effect."
    ]
  end
  
end

register_artifact(Artifact_TinkerersTools)