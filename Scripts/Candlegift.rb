class Candlegift < Aura
  attr_accessor :combat_cache
  attr_accessor :buff_map

  def self.get_base_stats
    return {
      :name => "Candlegift",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain a two-star Helena.",
      "Your units that start",
      "combat adjacent to Helena",
      "and survive permanently",
      "gain stacking ward."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init
    
    give_unit(Helena, 2)
    @buff_map = {}
    # cache units around a Helena at start of combat
    cache = Proc.new do |listen|
      listen.subscriber.combat_cache = []
      for u in listen.host.deployed
        for n in u.current_hex.get_neighbors
          next unless n.battler
          next unless n.battler.owner == listen.subscriber.owner
          next unless n.battler.name == "Helena"
          listen.subscriber.combat_cache.push(u)
          break
        end
      end
    end
    gen_subscription_to(@owner, :Deployed, cache)

    buff = Proc.new do |listen, streak|
      for u in listen.subscriber.combat_cache
        next if u.dead
        if !listen.subscriber.buff_map[u.id]
          listen.subscriber.buff_map[u.id] = Buff_Eternal.new(self, u, Impact.new(:WARD, 5))
        else
          listen.subscriber.buff_map[u.id].impacts[0].amount += 5
        end
      end
    end
    gen_subscription_to(@owner, :RoundResolved, buff)
  end

end

register_aura(Candlegift)