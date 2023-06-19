class Artifact_RangersBow < Artifact

  def self.get_base_stats
    return {
      :name       => "Ranger's Bow",
      :description => "Grants toughness and the Scout type.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Bow"],
      :impacts    => [
        [Impact, [:TOUGHNESS, 10]]
      ],
      :components => ["Burnished Plate", "Tinkerer's Tools"],
      :back   => [:TOUGHNESS, :UNIQUE],
      :synergy => :SCOUT,
      :unique => true
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants toughness and the Scout",
      "type."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.synergies.push(:SCOUT)
    @wielder.tink_synergies.push(:SCOUT)
    @wielder.owner.synergy_update(@wielder)
    for a in @wielder.owner.auras
      if a.enchants == :unit
        a.apply(@wielder)
      end
    end
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies.delete_at(@wielder.synergies.index(:SCOUT))
    @wielder.tink_synergies.delete_at(@wielder.synergies.index(:SCOUT))
    @wielder.owner.synergy_update(@wielder)
    super
  end
  
end

register_artifact(Artifact_RangersBow)