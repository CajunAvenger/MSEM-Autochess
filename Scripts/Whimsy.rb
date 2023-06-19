class Whimsy < Aura
  
  def self.get_base_stats
    return {
      :name => "Whimsy",
      :tier  => 2
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Bard.",
      "",
      "Gain a Mabil with a Nexus",
      "of Possibilities."
    ]
  end
  
  def self.sprite
    return "Bard"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Mabil with a Nexus of Possibilities and a Bard emblem
    give_unit_with(Mabil, Artifact_NexusOfPossibilities)

    @owner.synergy_handlers[:BARD].extra_counter += 1
    
  end

end

register_aura(Whimsy)