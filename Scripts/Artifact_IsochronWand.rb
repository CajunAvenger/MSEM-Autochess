class Artifact_IsochronWand < Artifact

  def self.get_base_stats
    return {
      :name       => "Isochron Wand",
      :description => "Grants archive and the Wizard type.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Wand"],
      :impacts    => [
        [Impact, [:ARCHIVE, 10]]
      ],
      :components => ["Warded Tome", "Tinkerer's Tools"],
      :back   => [:ARCHIVE, :UNIQUE],
      :synergy => :WIZARD,
      :unique => true
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants archive and the Wizard type."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.synergies.push(:WIZARD)
    @wielder.tink_synergies.push(:WIZARD)
    @wielder.owner.synergy_update(@wielder)
    for a in @wielder.owner.auras
      if a.enchants == :unit
        a.apply(@wielder)
      end
    end
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies.delete_at(@wielder.synergies.index(:WIZARD))
    @wielder.tink_synergies.delete_at(@wielder.synergies.index(:WIZARD))
    @wielder.owner.synergy_update(@wielder)
    super
  end
  
end

register_artifact(Artifact_IsochronWand)