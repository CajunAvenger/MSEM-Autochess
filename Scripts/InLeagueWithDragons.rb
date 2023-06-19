class InLeagueWithDragons < Aura
  
  def self.get_base_stats
    return {
      :name => "In League With Dragons",
      :tier  => 2
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Draconic.",
      "",
      "Gain a Boxue with a Lamp",
      "of Endless Possibilities."
    ]
  end
  
  def self.sprite
    return "Draconic"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Boxue with a Lamp and a Draconic emblem
    give_unit_with(Boxue, Artifact_LampOfEndlessPossibilities)
    
    @owner.synergy_handlers[:DRACONIC].extra_counter += 1
    
  end

end

register_aura(InLeagueWithDragons)