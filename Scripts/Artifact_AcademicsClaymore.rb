class Artifact_AcademicsClaymore < Artifact
  attr_accessor :stacks
  def self.get_base_stats
    return {
      :name       => "Academic's Claymore",
      :description => "Grants power and archive. Grants stacking power on attack, " +
        "and more on cast.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:POWER, 10]],
        [Impact, [:ARCHIVE, 10]]
      ],
      :components => ["Seishin's Edge", "Warded Tome"],
      :back   => [:POWER, :ARCHIVE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants power and archive. Grants",
      "stacking power on attack, and",
      "more on cast."
    ]
  end
  
  def extra_init
    @stacks = [Impact.new(:POWER, 0), nil]
    @impacts.push(@stacks[0])
  end
  
  def equip_to(target)
    super
    stack = Proc.new do |listen, attack_keys, i|
      mid = listen.host.owner.match.id
      if listen.subscriber.stacks[1] != mid
        listen.subscriber.stacks[0].amount = 0
        listen.subscriber.stacks[1] = mid
      end
      listen.subscriber.stacks[0].amount += 1
    end
    super_stack = Proc.new do |listen, attack_keys|
      mid = listen.host.owner.match.id
      if listen.subscriber.stacks[1] != mid
        listen.subscriber.stacks[0].amount = 0
        listen.subscriber.stacks[1] = mid
      end
      listen.subscriber.stacks[0].amount += 5
    end

    unstack = Proc.new do |listen, streak|
      listen.subscriber.stacks[0].amount = 0
    end
    
    @equip_listen = gen_subscription_to(@wielder, :Attacked, stack)
    @equip_listen2 = gen_subscription_to(@wielder, :UsedAbility, super_stack)
    @equip_listen3 = gen_subscription_to(@wielder.owner, :RoundEnd, unstack)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    @equip_listen2.clear_listener
    @equip_listen3.clear_listener
    super
  end
  
end

register_artifact(Artifact_AcademicsClaymore)