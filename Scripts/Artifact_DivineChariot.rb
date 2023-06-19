class Artifact_DivineChariot < Artifact

  def self.get_base_stats
    return {
      :name       => "Divine Chariot",
      :description => "Grants haste, life, and great movespeed.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Machine"],
      :impacts    => [
        [Impact, [:HASTE_MULTI, 0.1]],
        [Impact, [:MAX_LIFE, 10]]
      ],
      :components => ["Cinderblade", "Spirit Pendant"],
      :back   => [:HASTE, :MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
     "Grants haste, life, and large",
     "amounts of movespeed."
    ]
  end
  
  def equip_to(target)
    super
    @wielder.move += 3
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.move -= 3
    super
  end
  
end

register_artifact(Artifact_DivineChariot)