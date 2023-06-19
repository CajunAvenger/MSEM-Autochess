class Currency < Aura
  
  def self.get_base_stats
    return {
      :name => "Currency",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a huge amount of gold."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end

  def extra_init
    
    @owner.give_gold(40, self)
    
  end

end

register_aura(Currency)