class OverwhelmingArmies < Aura
  
  def self.get_base_stats
    return {
      :name => "Overwhelming Armies",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Helena and a",
      "Shionoshio, Ocean's Vow."
    ]
  end
  
  def self.sprite
    return "Dudette"
  end

  def extra_init
    
    # Gain a Helena and a Shionoshio, Ocean's Vow
    give_unit_and(Helena, Artifact_ShionoshioOceansVow)
    
  end

end

register_aura(OverwhelmingArmies)