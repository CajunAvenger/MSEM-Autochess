class Artifact_DominionCrown < Artifact

  def self.get_base_stats
    return {
      :name       => "Dominion Crown",
      :description => "Grants ward. Stuns enemies that cast nearby.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Armor"],
      :impacts    => [
        [Impact, [:WARD, 20]]
      ],
      :components => ["Mageweave Cloak", "Mageweave Cloak"],
      :back   => [:WARD]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants ward. Stuns enemies that",
      "cast near the wielder."
    ]
  end
  
  def equip_to(target)
    super
    stunner = Proc.new do |listen, emitter, *args|
      next if emitter.owner == listen.subscriber.wielder.owner
      next unless listen.subscriber.wielder.current_hex.get_neighbors.include?(emitter.current_hex)
      Debuff_Timed.new(listen.subscriber.wielder, emitter, Impact.new(:STUN, 1), 1.5)
    end

    setter = Proc.new do |listen|
      listen.subscriber.gen_subscription_to(listen.host.match, :UsedAbility, stunner)
    end
    @equip_listener = gen_subscription_to(@wielder.owner, :Deployed, setter)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listener.clear_listener
    super
  end
  
end

register_artifact(Artifact_DominionCrown)