class Artifact_BloodguardsHand < Artifact
  attr_accessor :stacks
  def self.get_base_stats
    return {
      :name       => "Bloodguard's Hand",
      :description => "Grants life. The first time each combat the wielder " +
        "would die, it becomes briefly invulnerable.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Scythe"],
      :impacts    => [
        [Impact, [:MAX_LIFE, 20]]
      ],
      :components => ["Spirit Pendant", "Spirit Pendant"],
      :back   => [:MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants life. The first time each",
      "combat the wielder would die, it",
      "becomes briefly invulnerable."
    ]
  end
  
  def equip_to(target)
    super
    save = Proc.new do |listen, *args|
      next if listen.subscriber.stacks == listen.host.owner.match.id
      listen.subscriber.stacks = listen.host.owner.match.id
      invul = Impact.new(:INVULNERABLE, 1)
      Buff_Timed.new(listen.subscriber, listen.host, invul, 2)
      ml = listen.host.get_value(:MAX_LIFE)
      listen.host.current_damage = ml-1
    end
    @equip_listener = gen_subscription_to(@wielder, :Dying, save)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listener.clear_listener
    super
  end
  
end

register_artifact(Artifact_BloodguardsHand)