class MinersBarracks < Aura
  
  def self.get_base_stats
    return {
      :name => "Miner's Barracks",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain extra gold each combat",
      "as long as you're on a win streak."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end
  
  def extra_init
    
    @owner.empowered.push(:mining)
  end

end

register_aura(MinersBarracks)