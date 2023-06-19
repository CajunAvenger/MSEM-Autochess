class Artifact_AstrinaTemperedByGlory < Artifact
  attr_accessor :astrina_stack
  def self.get_base_stats
    return {
      :name       => "Astrina, Tempered by Glory",
      :description => "Grants multistrike chance and life. Also grants " +
        "lifesteal stacking with each hit.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Sword"],
      :impacts    => [
        [Impact, [:MULTI, 10]],
        [Impact, [:MAX_LIFE, 10]]
      ],
      :components => ["Flintlock Pistol", "Spirit Pendant"],
      :back   => [:MULTI, :MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants multistrike chance and", 
      "life. Also grants lifesteal",
      "stacking with each hit."
    ]
  end

  def extra_init
    @astrina_stack = [Impact.new(:LIFESTEAL, 0.0), nil]
    @impacts.push(@astrina_stack[0])
  end
  
  def equip_to(target)
    super
    stack = Proc.new do |listen, attack_keys, i|
      mid = listen.host.owner.match.id
      if listen.subscriber.astrina_stack[1] != mid
        listen.subscriber.astrina_stack[0].amount = 0
        listen.subscriber.astrina_stack[1] = mid
      end
      listen.subscriber.astrina_stack[0].amount += 0.02
    end
    unstack = Proc.new do |listen, streak|
      listen.subscriber.astrina_stack[0].amount = 0
    end
    @equip_listen = gen_subscription_to(@wielder, :Attacked, stack)
    @equip_listen2 = gen_subscription_to(@wielder.owner, :RoundEnd, unstack)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    @equip_listen2.clear_listener
    super
  end
  
end

register_artifact(Artifact_AstrinaTemperedByGlory)