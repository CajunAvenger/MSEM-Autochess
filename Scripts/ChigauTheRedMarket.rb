class ChigauTheRedMarket < Aura
  
  def self.get_base_stats
    return {
      :name => "Chigau, the Red Market",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "The store is more likely to",
      "include Necromancers.",
      "When you combine Necromancers,",
      "if your Necromancer synergy is",
      "active, start next combat",
      "with a bonus skeleton token.",
      "Gain a Rain Zai."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    @owner.common_units.push(:NECROMANCER)
    @stacks = [0]
    
    # Set up listener to count starred up Necromancers
    stars = Proc.new do |listen, unit|
      console.log(unit.id)
      next unless unit.synergies.include?(:NECROMANCER)
      listen.subscriber.stacks[0] += 1
    end
    gen_subscription_to(@owner, :StarredUp, stars)
    
    bonus_skele = Proc.new do |listen|
      skeles = listen.subscriber.stacks[0]
      console.log(skeles)
      listen.subscriber.stacks[0] = 0
      next unless listen.host.synergy_handlers[:NECROMANCER].level > 0
      for i in 1..skeles
        listen.host.give_unit(Necromancer_Skeleton.new, self)
      end
    end
    gen_subscription_to(@owner, :Deployed, bonus_skele)
    
    # Gain an Rain
    give_unit(Rain)
    
  end


end

register_aura(ChigauTheRedMarket)