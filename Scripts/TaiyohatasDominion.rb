class TaiyohatasDominion < Aura
  
  def self.get_base_stats
    return {
      :name => "Taiyohata's Dominion",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "If you have multiple copies",
      "of a planeswalker in play,",
      "start combat with a Soldier",
      "token for each name."
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
        s = Commander_Soldier.new
        s.temp = true
        listen.host.give_unit(s, self)
      end
    end
    gen_subscription_to(@owner, :Deployed, collect)
    
  end

end

register_aura(TaiyohatasDominion)