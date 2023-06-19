class Artifact_Cinderblade < Artifact
  
  def self.get_base_stats
    return {
      :name   => "Cinderblade",
      :description => "Reduces delay between actions.",
      :cost   => 1,
      :type   => :component,
      :keys   => ["Sword"],
      :impacts => [[Impact, [:HASTE_MULTI, 0.1]]],
      :back   => [:HASTE]
    }
  end

  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants 10% increased haste."
    ]
  end

end

register_artifact(Artifact_Cinderblade)