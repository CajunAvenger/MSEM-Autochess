class HalcyonDaze < Aura
  
  def self.get_base_stats
    return {
      :name => "Halcyon Daze",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Chronomancer.",
      "",
      "Gain a Karina."
    ]
  end
  
  def self.sprite
    return "Chronomancer"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Karina and a Chronomancer emblem
    give_unit(Karina)
    
    @owner.synergy_handlers[:CHRONOMANCER].extra_counter += 1
    
  end

end

register_aura(HalcyonDaze)