class Artifact_CrownOfTheUrchinKing < Artifact

  def self.get_base_stats
    return {
      :name       => "Crown of the Urchin King",
      :description => "Grants toughness and life. Toughness increases over time. " +
      "Wielder becomes briefly invulnerable whenever an ally dies.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:TOUGHNESS, 10]],
        [Impact, [:MAX_LIFE, 10]],
        [Impact_Combat, [:TOUGHNESS, 50]]
      ],
      :components => ["Burnished Plate", "Spirit Pendant"],
      :back   => [:TOUGHNESS, :MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants toughness and life. Gives",
      "even more toughness over time.",
      "When allies die, wielder becomes",
      "invulnerable for a short time."
    ]
  end
  
  def equip_to(target)
    super
    invul = Proc.new do |listen, emitter, *args|
      next if emitter.owner != listen.subscriber.wielder.owner
      imp = Impact.new(:INVULNERABLE, 1)
      Buff_Timed.new(listen.subscriber, listen.subscriber.wielder, imp, 2)
    end
    
    setter = Proc.new do |listen|
      listen.subscriber.gen_subscription_to(listen.host.match, :Died, invul)
    end
    @equip_listener = gen_subscription_to(@wielder.owner, :Deployed, setter)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listener.clear_listener
    super
  end
  
end

register_artifact(Artifact_CrownOfTheUrchinKing)