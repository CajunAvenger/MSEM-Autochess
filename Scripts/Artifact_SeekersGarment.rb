class Artifact_SeekersGarment < Artifact

  def self.get_base_stats
    return {
      :name       => "Seeker's Garment",
      :description => "Grants ward and the Mirrorwalker type.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Armor"],
      :impacts    => [
        [Impact, [:WARD, 10]]
      ],
      :components => ["Mageweave Cloak", "Tinkerer's Tools"],
      :back   => [:WARD, :UNIQUE],
      :synergy => :MIRRORWALKER,
      :unique => true
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants ward and the Mirrorwalker",
      "type."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.synergies.push(:MIRRORWALKER)
    @wielder.tink_synergies.push(:MIRRORWALKER)
    @wielder.owner.synergy_update(@wielder)
    for a in @wielder.owner.auras
      if a.enchants == :unit
        a.apply(@wielder)
      end
    end
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies.delete_at(@wielder.synergies.index(:MIRRORWALKER))
    @wielder.tink_synergies.delete_at(@wielder.synergies.index(:MIRRORWALKER))
    @wielder.owner.synergy_update(@wielder)
    super
  end
  
end

register_artifact(Artifact_SeekersGarment)