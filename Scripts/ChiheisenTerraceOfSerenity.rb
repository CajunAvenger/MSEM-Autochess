class ChiheisenTerraceOfSerenity < Aura
  
  def self.get_base_stats
    return {
      :name => "Chiheisen, Terrace of Serenity",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "If you have multiple copies",
      "of a planeswalker in play,",
      "they gain mana amp and archive."
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
            Impact.new(:MANA_AMP, 20),
            Impact.new(:ARCHIVE, 20)
          ]
          Buff.new(self, u, imps)
        end
      end
    end
    gen_subscription_to(@owner, :Deployed, collect)
    
  end

end

register_aura(ChiheisenTerraceOfSerenity)