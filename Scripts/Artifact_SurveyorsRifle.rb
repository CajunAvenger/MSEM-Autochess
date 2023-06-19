class Artifact_SurveyorsRifle < Artifact

  def self.get_base_stats
    return {
      :name       => "Surveyor's Rifle",
      :description => "Grants multistrike chance and the Gunslinger type.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Gun"],
      :impacts    => [
        [Impact, [:MULTI, 10]]
      ],
      :components => ["Flintlock Pistol", "Tinkerer's Tools"],
      :back   => [:MULTI, :UNIQUE],
      :synergy => :GUNSLINGER,
      :unique => true
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants multistrike chance and the",
      "Gunslinger type."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.synergies.push(:GUNSLINGER)
    @wielder.tink_synergies.push(:GUNSLINGER)
    @wielder.owner.synergy_update(@wielder)
    for a in @wielder.owner.auras
      if a.enchants == :unit
        a.apply(@wielder)
      end
    end
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies.delete_at(@wielder.synergies.index(:GUNSLINGER))
    @wielder.tink_synergies.delete_at(@wielder.synergies.index(:GUNSLINGER))
    @wielder.owner.synergy_update(@wielder)
    super
  end
  
end

register_artifact(Artifact_SurveyorsRifle)