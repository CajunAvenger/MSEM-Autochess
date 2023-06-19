class StickyFingers < Aura
  
  def self.get_base_stats
    return {
      :name => "Sticky Fingers",
      :tier  => 2
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Rogue.",
      "",
      "Gain a Siraj with an",
      "Amulet Coin."
    ]
  end
  
  def self.sprite
    return "Rogue"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Siraj with an Amulet Coin and a Rogue emblem
    give_unit_with(Siraj, Artifact_AmuletCoin)
    
    @owner.synergy_handlers[:ROGUE].extra_counter += 1
    
  end

end

register_aura(StickyFingers)