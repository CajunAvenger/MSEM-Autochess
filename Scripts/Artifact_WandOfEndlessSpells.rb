class Artifact_WandOfEndlessSpells < Artifact

  def self.get_base_stats
    return {
      :name       => "Wand of Endless Spells",
      :description => "Grants exceptionally high stats, but slowly drains life.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Wand"],
      :impacts    => [
        [Impact, [:MULTI, 50]],
        [Impact, [:ARCHIVE, 100]]
      ],
      :components => ["Flintlock Pistol", "Warded Tome"],
      :back   => [:MULTI, :ARCHIVE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants exceptionally high stats,",
      "but slowly drains life."
    ]
  end
  
  def equip_to(target)
    super
    draining = Proc.new do |listen|
      next unless listen.host.deployed.include?(@wielder)
      DoT.new(self, @wielder, @wielder.get_value(:MAX_LIFE), 30)
    end
    @equip_listen = gen_subscription_to(@wielder.owner, :Deployed, draining)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_WandOfEndlessSpells)