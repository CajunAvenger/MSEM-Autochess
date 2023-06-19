class TheFutureIsNow < Aura
  
  def self.get_base_stats
    return {
      :name => "The Future is Now",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a huge amount of gold,",
      "but no longer gain interest."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end

  def extra_init
    
    @owner.give_gold(60, self)
    @owner.interest_cap = 0

  end

end

register_aura(TheFutureIsNow)