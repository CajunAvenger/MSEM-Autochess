class OneWithSeishin < Aura

  def self.get_base_stats
    return {
      :name => "One With Seishin",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a two-star Azamir.",
      "It takes up two team slots."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init
    
    aza = give_unit(Azamir, 2)
    aza.empowered.push(:TwoSlots)

  end

end

register_aura(OneWithSeishin)