class Artifact_DraconicBulwark < Artifact

  def self.get_base_stats
    return {
      :name       => "Draconic Bulwark",
      :description => "Grants lots of toughness, makes wielder immune to " +
        "multistrikes, and allows wielder to hit Aerials normally.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Machine"],
      :impacts    => [
        [Impact, [:TOUGHNESS, 60]],
        [Impact, [:HighSwing, 1]]
      ],
      :components => ["Burnished Plate", "Burnished Plate"],
      :back   => [:TOUGHNESS]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants lots of toughness, makes",
      "wielder immune to multistrikes,",
      "and allows wielder to hit Aerial",
      "units normally."
    ]
  end
  
  def equip_to(target)
    super
    deny_ms = Proc.new do |listen, attack_keys|
      attack_keys[:times] = 1 if attack_keys[:times] > 1
    end
    @equip_listen = gen_subscription_to(@wielder, :BeingAttacked, deny_ms)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_DraconicBulwark)