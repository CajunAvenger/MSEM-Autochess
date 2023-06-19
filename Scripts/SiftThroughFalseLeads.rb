class SiftThroughFalseLeads < Aura
  
  def self.get_base_stats
    return {
      :name => "Sift Through False Leads",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "You count as having an",
      "additional Investigator.",
      "",
      "Gain a Bahum."
    ]
  end
  
  def self.sprite
    return "Investigator"
  end
  
  def enchants
    return nil
  end

  def extra_init
    
    # Gain a Bahum and a Investigator emblem
    give_unit(Bahum)
    
    @owner.synergy_handlers[:INVESTIGATOR].extra_counter += 1
    
  end

end

register_aura(SiftThroughFalseLeads)