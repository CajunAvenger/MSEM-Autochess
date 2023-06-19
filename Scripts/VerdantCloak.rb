class VerdantCloak < Aura
  
  def self.get_base_stats
    return {
      :name => "Verdant Cloak",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Mageweave Cloak. Any",
      "completed artifact you build",
      "from it is Verdant, also granting",
      "bonus power, toughness,",
      "and mana amp."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    a = Artifact_MageweaveCloak.new
    a.empowered.push(:verdant)
    a.displayname += " (Verdant)"
    @owner.give_artifact(a)
    
  end
  
end

register_aura(VerdantCloak)