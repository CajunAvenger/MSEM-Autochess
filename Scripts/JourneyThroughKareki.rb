class JourneyThroughKareki < Aura
  
  def self.get_base_stats
    return {
      :name => "Journey through Kareki",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "If you have multiple copies of",
      "a planeswalker in play, they",
      "gain power and toughness."
    ]
  end
  
  def self.sprite
    return "Collect"
  end

  def extra_init
    
    collect = Proc.new do |listen, unit|
      map = {}
      for u in listen.host.deployed
        if !map.include?(u.name)
          map[u.name] = []
        end
        map[u.name].push(u)
      end
      for id, ar in map
        next unless ar.length > 1
        for u in ar
          imps = [
            Impact.new(:POWER, 20),
            Impact.new(:TOUGHNESS, 20)
          ]
          Buff.new(self, u, imps)
        end
      end
    end
    gen_subscription_to(@owner, :Deployed, collect)
    
  end

end

register_aura(JourneyThroughKareki)