class Artifact_NeedleDoll < Artifact

  def self.get_base_stats
    return {
      :name       => "Needle Doll",
      :description => "Grants toughness and ward. Enemies that attack or cast " +
        "nearby lose life.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:TOUGHNESS, 10]],
        [Impact, [:WARD, 10]]
      ],
      :components => ["Burnished Plate", "Mageweave Cloak"],
      :back   => [:TOUGHNESS, :WARD]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants toughness and ward.",
      "Enemies that attack or cast near",
      "the wielder lose life."
    ]
  end
  
  def equip_to(target)
    super
    drainer = Proc.new do |listen, emitter, *args|
      next if emitter.owner == listen.subscriber.wielder.owner
      next unless listen.subscriber.wielder.current_hex.get_neighbors.include?(emitter.current_hex)
      ml = emitter.get_value(:MAX_LIFE)
      Damage.new(listen.subscriber.wielder, emitter, 0, 0.05*ml).resolve
    end
    
    setter = Proc.new do |listen|
      listen.subscriber.gen_subscription_to(listen.host.match, :DoneAttacking, drainer)
      listen.subscriber.gen_subscription_to(listen.host.match, :UsedAbility, drainer)
    end
    @equip_listener = gen_subscription_to(@wielder.owner, :Deployed, setter)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listener.clear_listener
    super
  end
  
end

register_artifact(Artifact_NeedleDoll)