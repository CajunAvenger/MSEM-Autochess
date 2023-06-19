class Artifact_TrickedOutHoverboard < Artifact

  def self.get_base_stats
    return {
      :name       => "Tricked-Out Hoverboard",
      :description => "Grants haste and the Aerial type.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Machine"],
      :impacts    => [
        [Impact, [:HASTE_MULTI, 0.1]]
      ],
      :components => ["Cinderblade", "Tinkerer's Tools"],
      :back   => [:HASTE, :UNIQUE],
      :synergy => :AERIAL,
      :unique => true
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants haste and the Aerial type."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.synergies.push(:AERIAL)
    @wielder.tink_synergies.push(:AERIAL)
    @wielder.aerial += 1
    @wielder.owner.synergy_update(@wielder)
    for a in @wielder.owner.auras
      if a.enchants == :unit
        a.apply(@wielder)
      end
    end
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies.delete_at(@wielder.synergies.index(:AERIAL))
    @wielder.tink_synergies.delete_at(@wielder.synergies.index(:AERIAL))
    @wielder.aerial -= 1
    @wielder.owner.synergy_update(@wielder)
    super
  end
  
end

register_artifact(Artifact_TrickedOutHoverboard)