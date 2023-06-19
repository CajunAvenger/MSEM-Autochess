class Disassociate < Aura
  
  def self.get_base_stats
    return {
      :name => "Disassociate",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "When you sell a planeswalker,",
      "un-combine all of its artifacts",
      "into components."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end
  
  def self.can_be_given_to?(player)
    return 0 if player.auras.any?(self)
    return 0 if player.auras.any?(GoldenAge)
    return 1
  end

  def extra_init
    
    @owner.empowered.push(:uncombine)
  end

end

register_aura(Disassociate)