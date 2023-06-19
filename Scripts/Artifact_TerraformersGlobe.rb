class Artifact_TerraformersGlobe < Artifact

  def self.get_base_stats
    return {
      :name       => "Terraformer's Globe",
      :description => "Grants mana amp and the Alara type.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Machine"],
      :impacts    => [
        [Impact, [:MANA_AMP, 10]]
      ],
      :components => ["Iron Signet", "Tinkerer's Tools"],
      :back   => [:MANA_AMP, :UNIQUE],
      :synergy => :ALARA,
      :unique => true
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants mana amp and the Alara",
      "type."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.synergies.push(:ALARA)
    @wielder.tink_synergies.push(:ALARA)
    @wielder.owner.synergy_update(@wielder)
    for a in @wielder.owner.auras
      if a.enchants == :unit
        a.apply(@wielder)
      end
    end
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies.delete_at(@wielder.synergies.index(:ALARA))
    @wielder.tink_synergies.delete_at(@wielder.synergies.index(:ALARA))
    @wielder.owner.synergy_update(@wielder)
    super
  end
  
end

register_artifact(Artifact_TerraformersGlobe)