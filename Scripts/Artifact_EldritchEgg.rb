class Artifact_EldritchEgg < Artifact
  attr_accessor :stacks
  def self.get_base_stats
    return {
      :name       => "Eldritch Egg",
      :description => "Gain a stack whenever the bearer dies in combat. " +
        "At sufficient stacks, hatches into the most expensive two-star" +
        "planeswalker that shares a synergy with the bearer.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Trinket"],
      :impacts    => [],
      :back   => [:UNIQUE]
    }
  end
  
  def extra_init
    @stacks = 0
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Gain a stack whenever the bearer",
      "dies. At sufficient stacks, hatches",
      "into the most expensive two-star",
      "planeswalker that shares a",
      "synergy with the bearer."
    ]
  end
  
  def equip_to(target)
    super
    crack = Proc.new do |listen, *args|
      listen.subscriber.stacks += 1
      if listen.subscriber.stacks == 5
        u = listen.host
        opts = []
        for s in u.synergies
          ws = $planeswalkers[s]
          for w in ws
            opts.push(w) unless opts.include?(w)
          end
        end
        newboi = $walker_pool.roll_from_opts(opts, 5, true)
        if newboi
          nb = newboi.new(listen.host.owner, 2)
          listen.host.owner.give_unit(nb)
        end
        listen.subscriber.clear_artifact
      end
    end
    @equip_listen = gen_subscription_to(@wielder, :Died, crack)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_EldritchEgg)