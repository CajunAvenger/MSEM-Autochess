class Artifact_HylesGift < Artifact
  attr_accessor :dashed
  def self.get_base_stats
    return {
      :name       => "Hyle's Gift",
      :description => "Bearer becomes cloaked and dashes to preferred" +
        "range after hit by the first hostile spellcast.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:MULTI, 10]],
        [Impact, [:WARD, 10]]
      ],
      :components => ["Flintlock Pistol", "Mageweave Cloak"],
      :back   => [:MULTI, :WARD]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Bearer becomes cloaked and dashes",
      "to preferred range after hit by",
      "the first hostile spellcast."
    ]
  end
  
  def equip_to(target)
    super
    dash_check = Proc.new do |listen, damage_event|
      next unless damage_event.is_a?(Damage_Ability)
      next if listen.subscriber.dashed == listen.subscriber.owner.match.id
      listen.subscriber.dashed = listen.subscriber.owner.match.id
      Buff_Timed.new(listen.subscriber, listen.host, Impact.new(:CLOAK, 1), 3)
      if listen.host.aggro
        r = listen.host.get_value(:RANGE)
        areas = listen.host.aggro.current_hex.get_area_hexes(r)
        dists = areas[1].reverse
        moved = false
        for d in dists
          for h in d[:hexes]
            next if h.battler
            moved = h.set_battler(listen.host)
            break if moved
          end
          break if moved
        end
      end
    end
    @equip_listen = gen_subscription_to(@wielder, :Damaged, dash_check)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_HylesGift)