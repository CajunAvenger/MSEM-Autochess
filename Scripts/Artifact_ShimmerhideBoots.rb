class Artifact_ShimmerhideBoots < Artifact

  def self.get_base_stats
    return {
      :name       => "Shimmerhide Boots",
      :description => "Grants multistrike chance and haste. " + 
        "Also grants chance for incoming attacks to be absorbed " +
        "by summoned duplicate.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Shoes"],
      :impacts    => [
        [Impact, [:MULTI, 10]],
        [Impact, [:HASTE_MULTI, 0.1]],
        [Impact, [:POWER, 0]],
        [Impact, [:TOUGHNESS, 0]]
      ],
      :components => ["Flintlock Pistol", "Cinderblade"],
      :back   => [:MULTI, :HASTE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants multistrike chance and",
      "haste. Also grants chance for",
      "incoming attacks to be absorbed by",
      "summoned duplicate."
    ]
  end
  
  def equip_to(target)
    super
    whiff = Proc.new do |listen, attack_keys|
      if rand(100) < 20
        console.log("dodge")
        attack_keys[:times] = 0
        if listen.subscriber.empowered.include?(:reflected)
          listen.subscriber.impacts[2].amount += 10
          listen.subscriber.impacts[3].amount += 10
        end
      end
      console.log("dodge out")
    end
    @equip_listen = gen_subscription_to(@wielder, :BeingAttacked, whiff)
    
    unstack = Proc.new do |listen, *args|
      listen.subscriber.impacts[2].amount = 0
      listen.subscriber.impacts[3].amount = 0
    end
    @equip_listen2 = gen_subscription_to(@wielder.owner, :RoundResolved, unstack)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    @impacts[2].amount = 0
    @impacts[3].amount = 0
    super
  end
  
end

register_artifact(Artifact_ShimmerhideBoots)