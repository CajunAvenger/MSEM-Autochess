class Artifact_AmuletOfLoyalties < Artifact

  def self.get_base_stats
    return {
      :name       => "Amulet of Loyalties",
      :description => "Wielder gains all your and your opponent's synergy bonuses, " +
        "but doesn't count towards their level.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Trinket"],
      :impacts    => [],
      :back   => [:UNIQUE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Wielder gains all your and your",
      "opponent's synergy bonuses, but",
      "doesn't count towards their level."
    ]
  end
  
  def equip_to(target)
    super
    # give wielder all synergies
    new_synergies = $synergies.keys - @wielder.synergies
    @wielder.synergies = $synergies.keys
    @wielder.leech_synergies = new_synergies
    
    # have wielder leech off all owner's synergies
    for id, s in @wielder.owner.synergy_handlers
      unless s.members.include?(@wielder)
        s.add_member(@wielder, new_synergies.include?(id))
        s.apply(@wielder) if s.blanketer
        s.match_apply(@wielder) if $processor_status == :combat_phase
      end
    end
    
    # Proc to unleech from opponents synergies at end of combat 
    debuff = Proc.new do |listen|
      console.log("debuff")
      for id, s in listen.host.synergy_handlers
        console.log(id)
        s.remove_member(listen.subscriber)
        s.unapply(listen.subscriber) if s.blanketer
      end
    end
    
    # Proc to leech from opponent's synergies at start of combat
    sneak_in = Proc.new do |listen|
      op = listen.host.opponent
      
      for id, s in op.synergy_handlers
        unless s.members.include?(listen.subscriber.wielder)
          s.add_member(listen.subscriber.wielder, true)
          s.apply(listen.subscriber.wielder) if s.blanketer
          s.match_apply(listen.subscriber.wielder) if s.deployer
        end
      end
      l = listen.subscriber.wielder.gen_subscription_to(op, :SynergyUnlocked, debuff)
      l.fragile = true
    end
    @equip_listener = gen_subscription_to(@wielder.owner, :SynergyLocked, sneak_in)
    #@equip_listener = gen_subscription_to(@wielder.owner, :OpponentPreparing, sneak_in)
  end
  
  def unequip_from(dont_trigger = false)
    @wielder.synergies = @wielder.get_base_stats[:synergies] + @wielder.tink_synergies
    for id, s in @wielder.owner.synergy_handlers
      unless @wielder.synergies.include?(s.key)
        s.remove_member(@wielder)
        #s.unapply(@wielder) if s.blanketer
      end
    end
    super
  end
  
end

register_artifact(Artifact_AmuletOfLoyalties)