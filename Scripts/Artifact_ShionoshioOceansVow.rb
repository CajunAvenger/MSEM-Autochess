class Artifact_ShionoshioOceansVow < Artifact

  def self.get_base_stats
    return {
      :name       => "Shionoshio, Ocean's Vow",
      :description => "Grants life and the Commander type.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Sword"],
      :impacts    => [
        [Impact, [:MAX_LIFE, 10]]
      ],
      :components => ["Spirit Pendant", "Tinkerer's Tools"],
      :back   => [:MAX_LIFE, :UNIQUE],
      :synergy => :COMMANDER,
      :unique => true
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants life and the Commander",
      "type."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.synergies.push(:COMMANDER)
    @wielder.tink_synergies.push(:COMMANDER)
    @wielder.owner.synergy_update(@wielder)
    for a in @wielder.owner.auras
      if a.enchants == :unit
        a.apply(@wielder)
      end
    end
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies.delete_at(@wielder.synergies.index(:COMMANDER))
    @wielder.tink_synergies.delete_at(@wielder.synergies.index(:COMMANDER))
    @wielder.owner.synergy_update(@wielder)
    super
  end
  
end

register_artifact(Artifact_ShionoshioOceansVow)