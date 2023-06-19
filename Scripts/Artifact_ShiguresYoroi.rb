class Artifact_ShiguresYoroi < Artifact
  attr_accessor :stacks
  def self.get_base_stats
    return {
      :name       => "Shigure's Yoroi",
      :description => "Grants archive and toughness. Grants even more " +
        "archive whenever the wielder takes damage.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Armor"],
      :impacts    => [
        [Impact, [:ARCHIVE, 10]],
        [Impact, [:TOUGHNESS, 10]]
      ],
      :components => ["Warded Tome", "Burnished Plate"],
      :back   => [:ARCHIVE, :TOUGHNESS]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants archive and toughness.",
      "Grants even more archive whenever",
      "the wielder takes damage."
    ]
  end
  
  def extra_init
    @stacks = [Impact.new(:ARCHIVE, 0), nil]
    @impacts.push(@stacks[0])
  end
  
  def equip_to(target)
    super
    stack = Proc.new do |listen, attack_keys|
      mid = listen.host.owner.match.id
      if listen.subscriber.stacks[1] != mid
        listen.subscriber.stacks[0].amount = 0
        listen.subscriber.stacks[1] = mid
      end
      listen.subscriber.stacks[0].amount += 1
    end

    unstack = Proc.new do |listen, streak|
      listen.subscriber.stacks[0].amount = 0
    end
    
    @equip_listen = gen_subscription_to(@wielder, :Damaged, stack)
    @equip_listen2 = gen_subscription_to(@wielder.owner, :RoundEnd, unstack)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    @equip_listen2.clear_listener
    super
  end
  
end

register_artifact(Artifact_ShiguresYoroi)