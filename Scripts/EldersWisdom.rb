class EldersWisdom < Aura
  
  def self.get_base_stats
    return {
      :name => "Elder's Wisdom",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Elder.",
      "",
      "Gain a Felice."
    ]
  end
  
  def self.sprite
    return "Elder"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Felice and a Elder emblem
    give_unit(Felice)
    
    @owner.synergy_handlers[:ELDER].extra_counter += 1
    
  end

end

register_aura(EldersWisdom)