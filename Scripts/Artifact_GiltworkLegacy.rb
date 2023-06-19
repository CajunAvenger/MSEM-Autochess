class Artifact_GiltworkLegacy < Artifact

  def self.get_base_stats
    return {
      :name       => "Giltwork Legacy",
      :description => "Grants archive and max life. After casting, restores a " +
        "percentage of max life to wielder and ally closest to death.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Sword"],
      :impacts    => [
        [Impact, [:ARCHIVE, 10]],
        [Impact, [:MAX_LIFE, 10]]
      ],
      :components => ["Warded Tome", "Spirit Pendant"],
      :back   => [:ARCHIVE, :MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants archive and max life. After",
      "casting, restores a percentage of",
      "max life to wielder and ally",
      "closest to death."
    ]
  end
  
  def equip_to(target)
    super
    restore = Proc.new do |listen, *args|
      heal = 0.1 * listen.host.get_value(:MAX_LIFE)
      listen.host.apply_heal(Heal.new(heal))
      l = [99999, nil]
      for u in listen.host.owner.deployed
        next if u == listen.host
        li = u.get_life
        if li < l[0]
          l = [li, u]
        end
      end
      next unless l[1]
      l[1].apply_heal(Heal.new(heal))
    end
    
    @equip_listen = gen_subscription_to(@wielder, :UsedAbility, restore)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_GiltworkLegacy)