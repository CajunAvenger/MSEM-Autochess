class FlightOfThePhoenix < Aura
  
  def self.get_base_stats
    return {
      :name => "Flight of the Phoenix",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Necromancer.",
      "",
      "Gain a Edarna."
    ]
  end
  
  def self.sprite
    return "Necromancer"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Edarna and a Necromancer emblem
    give_unit(Edarna)
    
    @owner.synergy_handlers[:NECROMANCER].extra_counter += 1
    
  end

end

register_aura(FlightOfThePhoenix)