class MarchOfTheGray < Aura
  
  def self.get_base_stats
    return {
      :name => "March of the Gray",
      :tier  => 2
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Necromancer.",
      "",
      "Gain a Rain Zai with a",
      "Hallowed Fragment."
    ]
  end
  
  def self.sprite
    return "Necromancer"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Rain Zai with a Hallowed Fragment and a Necromancer emblem
    give_unit_with(Rain, Artifact_HallowedFragment)
    
    @owner.synergy_handlers[:NECROMANCER].extra_counter += 1
    
  end

end

register_aura(MarchOfTheGray)