class TimeAfterTime < Aura
  
  def self.get_base_stats
    return {
      :name => "Time After Time",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Bard.",
      "",
      "Gain a Mabil."
    ]
  end
  
  def self.sprite
    return "Bard"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Mabil and a Bard emblem
    give_unit(Mabil)
    
    @owner.synergy_handlers[:BARD].extra_counter += 1
    
  end

end

register_aura(TimeAfterTime)