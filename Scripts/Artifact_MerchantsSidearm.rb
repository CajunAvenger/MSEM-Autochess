class Artifact_MerchantsSidearm < Artifact

  def self.get_base_stats
    return {
      :name       => "Merchant's Sidearm",
      :description => "Grants power and haste. Also gain gold on kill.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Gun"],
      :impacts    => [
        [Impact, [:POWER, 10]],
        [Impact, [:HASTE_MULTI, 0.1]]
      ],
      :components => ["Seishin's Edge", "Cinderblade"],
      :back   => [:POWER, :HASTE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants power and haste.",
      "Gain gold on kill."
    ]
  end
  
  def equip_to(target)
    super
    ka_ching = Proc.new do |listen, killer, *args|
      listen.host.owner.give_gold(listen.host.level, self)
      loot = new_animation_sprite
      loot.bitmap = RPG::Cache.icon("loot.png")
      loot.z = 6100
      loot.center_on(listen.host.sprite)
      loot.y -= 10
      loot.add_translate(0, 10, 0.3*listen.host.fps)
      loot.add_fade_to(0, 0.5*listen.host.fps)
      loot.add_dispose
    end
    @death_listen = gen_subscription_to(@wielder, :Killed, ka_ching)
  end
  
  def unequip_from(dont_trigger = false)
    @death_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_MerchantsSidearm)