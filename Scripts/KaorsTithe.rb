class KaorsTithe < Aura
  
  def self.get_base_stats
    return {
      :name => "Kaor's Tithe",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your interest is calculated",
      "off your opponent's gold",
      "reserves if they have more",
      "gold than you."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end
  
  def self.can_be_given_to?(player)
    return 0 if player.auras.any?(self)
    return 0 if player.auras.any?(TheFutureIsNow)
    return 1
  end

  def extra_init
    
    @owner.empowered.push(:tithe)
  end

end

register_aura(KaorsTithe)