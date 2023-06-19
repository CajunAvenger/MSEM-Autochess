class Theocracy < Aura
  
  def self.get_base_stats
    return {
      :name => "Holy War",
      :tier  => 2
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Cleric.",
      "",
      "Gain a Helena with a",
      "Divine Chariot."
    ]
  end
  
  def self.sprite
    return "Cleric"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Helena with a Divine Chariot and a Cleric emblem
    give_unit_with(Helena, Artifact_DivineChariot)

    @owner.synergy_handlers[:CLERIC].extra_counter += 1
    
  end

end

register_aura(Theocracy)