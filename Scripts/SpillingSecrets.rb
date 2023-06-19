class SpillingSecrets < Aura
  
  def self.get_base_stats
    return {
      :name => "Spilling Secrets",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Mei and a",
      "Seeker's Garment."
    ]
  end
  
  def self.sprite
    return "Dudette"
  end

  def extra_init
    
    # Gain a Mei and a Seeker's Garment
    give_unit_and(Mei, Artifact_SeekersGarment)
    
  end

end

register_aura(SpillingSecrets)