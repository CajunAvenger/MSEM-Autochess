class AmberReserves < Aura
  
  def self.get_base_stats
    return {
      :name => "Amber Reserves",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your first shop refresh",
      "each round is free."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end

  def extra_init
    
    @owner.empowered.push(:amber)

  end

end

register_aura(AmberReserves)