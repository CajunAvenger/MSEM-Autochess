class JourneyToTheZhedina < Aura
  
  def self.get_base_stats
    return {
      :name => "Journey to the Zhedina",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "If you have multiple copies",
      "of a planeswalker in play,",
      "they each gain bonus power",
      "when the other attacks."
    ]
  end
  
  def self.sprite
    return "Collect"
  end

  def extra_init
    
    @stacks = [-1, {}]
    
    collect = Proc.new do |listen, unit, *args|
      if listen.subscriber.stacks[0] != listen.host.match.id
        listen.subscriber.stacks = [listen.host.match.id, {}]
      end
      for u in listen.host.deployed
        next if u == unit
        next unless u.name == unit.name
        if listen.subscriber.stacks[1].include?(u.id)
          listen.subscriber.stacks[1][u.id].amount += 1
        else
          listen.subscriber.stacks[1][u.id] = Impact.new(:POWER, 1)
          b = Buff.new(self, u, listen.subscriber.stacks[1][u.id])
        end
      end
    end
    gen_subscription_to(@owner, :Attacking, collect)
  end


end

register_aura(JourneyToTheZhedina)