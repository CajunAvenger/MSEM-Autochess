class GatheringTheGang < Aura

  def self.get_base_stats
    return {
      :name => "Gathering the Gang",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a Mari, a Mei,",
      "and a two-star Xiong."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init

    give_unit(Mari)
    give_unit(Mei)
    give_unit(Xiong, 2)

  end

end

register_aura(GatheringTheGang)