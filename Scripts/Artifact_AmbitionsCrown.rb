class Artifact_AmbitionsCrown < Artifact

  def self.get_base_stats
    return {
      :name       => "Ambition's Crown",
      :description => "Increases the maximum team size by 1.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [],
      :components => ["Tinkerer's Tools", "Tinkerer's Tools"],
      :back   => [:UNIQUE],
      :unique => true
    }
  end
  
  def equip_to(target)
    super
    @wielder.owner.add_impact(Impact.new(:AmbitionSlot, 1))
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Increases your maximum team size",
      "by 1."
    ]
  end
  
end

register_artifact(Artifact_AmbitionsCrown)