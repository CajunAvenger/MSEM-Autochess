class Artifact_AetherlockPistol < Artifact

  def self.get_base_stats
    return {
      :name       => "Aetherlock Pistol",
      :description => "Grants multistrike chance and mana amp. " + 
        "Also grants on-hit damage scaling with amount of mana amp.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Gun"],
      :impacts    => [
        [Impact, [:MULTI, 10]],
        [Impact, [:MANA_AMP, 10]]
      ],
      :components => ["Flintlock Pistol", "Iron Signet"],
      :back   => [:MULTI, :MANA_AMP]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants multistrike chance, mana",
      "amp, and grants on-hit damage",
      "scaling with amount of mana amp."
    ]
  end
  
  def equip_to(target)
    super
    boom = Proc.new do |listen, attack_keys|
      attack_keys[:extra_p] += 20*listen.host.mana_amp
    end
    @equip_listen = gen_subscription_to(@wielder, :Attacking, boom)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_AetherlockPistol)