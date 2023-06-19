class Villainy < Aura
  
  def self.get_base_stats
    return {
      :name => "Villainy",
      :tier  => 2
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Elder.",
      "",
      "Gain a Velir."
    ]
  end
  
  def self.sprite
    return "Elder"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Velir and a Elder emblem
    give_unit(Velir)
    
    @owner.synergy_handlers[:ELDER].extra_counter += 1
    
  end

end

register_aura(Villainy)