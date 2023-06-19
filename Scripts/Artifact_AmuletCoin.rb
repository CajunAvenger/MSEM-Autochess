class Artifact_AmuletCoin < Artifact
  attr_accessor :coin_stack
  Base_mana = 20
  
  def self.get_base_stats
    return {
      :name       => "Amulet Coin",
      :description => "Grants haste and mana amp. Grants more mana amp "+
        "whenever wielder or nearby ally attacks.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:HASTE_MULTI, 0.1]]
      ],
      :components => ["Cinderblade", "Iron Signet"],
      :back   => [:HASTE, :MANA_AMP]
    }
  end
  
  def extra_init
    @coin_stack = [Impact.new(:MANA_AMP, Base_mana), nil]
    @impacts.push(@coin_stack[0])
  end

  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
     "Grants haste and mana amp. Grants",
     "more mana amp whenever wielder",
     "or a nearby ally attacks."
    ]
  end
  
  def equip_to(target)
    super
    
    # Proc that stacks the coin impact
    # triggers whenever anything attacks, filter in the proc
    stack = Proc.new do |listen, attacker, attack_keys, i|
      next if attacker.owner != @wielder.owner
      valid = false
      valid = true if attacker == @wielder
      unless valid
        ns = attack_keys[:attacker].current_hex.get_neighbors
        for n in ns
          next unless n.battler
          valid = true if n.battler == @wielder
        end
      end
      next unless valid
      listen.subscriber.coin_stack[0].amount += 5
    end
    
    # Proc that subscribes to the current match
    # triggers when owner deploys
    stacker = Proc.new do |listen|
      if listen.subscriber.coin_stack[1].is_a?(Listener)
        listen.subscriber.coin_stack[1].clear_listener
      end
      l = gen_subscription_to(listen.host.match, :Attacked, stack)
      listen.subscriber.coin_stack[1] = l
    end
    
    # Proc that resets the coin impact
    # triggers whenever the round ends
    unstack = Proc.new do |listen, streak|
      listen.subscriber.coin_stack[0].amount = Base_mana
    end
    
    @equip_listen = gen_subscription_to(@wielder.owner, :Deployed, stacker)
    @equip_listen2 = gen_subscription_to(@wielder.owner, :RoundEnd, unstack)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_AmuletCoin)