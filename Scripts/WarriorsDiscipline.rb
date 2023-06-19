class WarriorsDiscipline < Aura
  
  def self.get_base_stats
    return {
      :name => "Warrior's Discipline",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Mafua and a",
      "Hero's Axe."
    ]
  end
  
  def self.sprite
    return "Dude"
  end

  def extra_init
    
    # Gain a Mafua and a Hero's Axe
    give_unit_and(Mafua, Artifact_HerosAxe)
    
  end

end

register_aura(WarriorsDiscipline)