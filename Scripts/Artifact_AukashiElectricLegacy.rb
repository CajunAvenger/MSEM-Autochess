class Artifact_AukashiElectricLegacy < Artifact

  def self.get_base_stats
    return {
      :name       => "Aukashi, Electric Legacy",
      :description => "Grants power and multistrike chance. " +
        "Stats are transferred to nearest ally on death.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Sword"],
      :impacts    => [
        [Impact, [:POWER, 10]],
        [Impact, [:MULTI, 10]]
      ],
      :components => ["Seishin's Edge", "Flintlock Pistol"],
      :back   => [:POWER, :MULTI]
    }
  end
  
  def self.get_description
    return [
    #"Grants power and multistrike chan",
      "Grants power and multistrike",
      "chance. Stats are transferred to",
      "nearest ally on death."
    ]
  end
  
  def equip_to(target)
    super
    transfer = Proc.new do |listen, dead_man, old_hex, damage_event|
      ch = old_hex.get_closest_ally(dead_man.owner)
      next unless ch
      efs = build_impacts(get_base_stats[:impacts])
      Buff.new(self, ch.battler, efs, "Electric Legacy")
    end
    @death_listen = gen_subscription_to(@wielder, :Died, transfer)
  end
  
  def unequip_from(dont_trigger = false)
    @death_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_AukashiElectricLegacy)