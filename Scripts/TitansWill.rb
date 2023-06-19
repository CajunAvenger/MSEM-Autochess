class TitansWill < Aura
  attr_accessor :match_listeners
  def self.get_base_stats
    return {
      :name => "Titan's Will",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Non-Elder units on both",
      "sides deal reduced damage.",
      "Gain an Azamir."
    ]
  end

  def self.sprite
    return "Buff"
  end
  
  def extra_init
    # Gain an Azamir
    give_unit(Azamir)
    
    @match_listeners = []
    
    # debuff everything
    debuffer = Proc.new do |listen|
      ps = [listen.host.player1, listen.host.player2]
      for p in ps
        console.log(p.id)
        for u in p.deployed
          console.log(u.id)
          apply(u)
        end
      end
    end
    
    # debuff things as they're summoned or revived
    debuffer2 = Proc.new do |listen, unit, *args|
      listen.subscriber.enchanting.delete(unit)
      apply(unit)
    end
    
    # set listener that updates subscription
    matcher = Proc.new do |listen|
      for l in listen.subscriber.match_listeners
        l.clear_listener
      end
      # debuff everything on round start, summon, and revive
      l1 = gen_subscription_to(listen.host.match, :RoundStart, debuffer)
      l2 = gen_subscription_to(listen.host.match, :Summoned, debuffer2)
      l3 = gen_subscription_to(listen.host.match, :Revived, debuffer2)
      listen.subscriber.match_listeners = [l1, l2, l3]
    end
    
    gen_subscription_to(@owner, :Deployed, matcher)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return if unit.synergies.include?(:ELDER)
    imps = [
      Impact.new(:POWER_MULTI, -0.2)
    ]
    Debuff.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(TitansWill)