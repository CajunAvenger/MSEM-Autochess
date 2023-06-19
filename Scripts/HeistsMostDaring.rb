class HeistsMostDaring < Aura
  
  def self.get_base_stats
    return {
      :name => "Heists Most Daring",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Rogue.",
      "",
      "Gain a Siraj."
    ]
  end
  
  def self.sprite
    return "Rogue"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Siraj and a Rogue emblem
    give_unit(Siraj)
    
    @owner.synergy_handlers[:ROGUE].extra_counter += 1
    
  end

end

register_aura(HeistsMostDaring)