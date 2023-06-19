class Dracosoul < Aura
  
  def self.get_base_stats
    return {
      :name => "Dracosoul",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Draconic.",
      "",
      "Gain a Boxue."
    ]
  end
  
  def self.sprite
    return "Draconic"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Boxue and a Draconic emblem
    give_unit(Boxue)
    
    @owner.synergy_handlers[:DRACONIC].extra_counter += 1
    
  end

end

register_aura(Dracosoul)