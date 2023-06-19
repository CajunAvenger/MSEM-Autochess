class AllThatGlitters < Aura
  
  def self.get_base_stats
    return {
      :name => "All That Glitters",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain bonus gold now, and",
      "increase your interest cap."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end

  def extra_init
    
    @owner.give_gold(20, self)
    @owner.interest_cap += 2 unless @owner.interest_cap == 0

  end

end

register_aura(AllThatGlitters)