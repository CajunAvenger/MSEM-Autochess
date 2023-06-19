class Artifact_HerosAxe < Artifact

  def self.get_base_stats
    return {
      :name       => "Hero's Axe",
      :description => "Grants power and the Warrior type.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Axe"],
      :impacts    => [
        [Impact, [:POWER, 10]]
      ],
      :components => ["Seishin's Edge", "Tinkerer's Tools"],
      :back   => [:POWER, :UNIQUE],
      :synergy => :WARRIOR,
      :unique => true
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants power and the Warrior type."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.synergies.push(:WARRIOR)
    @wielder.tink_synergies.push(:WARRIOR)
    @wielder.owner.synergy_update(@wielder)
    for a in @wielder.owner.auras
      if a.enchants == :unit
        a.apply(@wielder)
      end
    end
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies.delete_at(@wielder.synergies.index(:WARRIOR))
    @wielder.tink_synergies.delete_at(@wielder.synergies.index(:WARRIOR))
    @wielder.owner.synergy_update(@wielder)
    super
  end
  
end

register_artifact(Artifact_HerosAxe)