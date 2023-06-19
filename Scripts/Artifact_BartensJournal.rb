class Artifact_BartensJournal < Artifact

  def self.get_base_stats
    return {
      :name       => "Barten's Journal",
      :description => "Grants mana amp and ward. Wielder and allies that start " +
        "adjacent to it gain a shield that blocks the first spell against them " +
        "each combat.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Book"],
      :impacts    => [
        [Impact, [:MANA_AMP, 10]],
        [Impact, [:WARD, 10]]
      ],
      :components => ["Iron Signet", "Mageweave Cloak"],
      :back   => [:MANA_AMP, :WARD]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants mana amp and ward.",
      "Wielder and allies that start",
      "adjacent to it gain a shield that",
      "blocks the first spell against them."
    ]
  end
  
  def equip_to(target)
    super
    # Proc that sets up the buff
    # triggers when player deploys
    shields_up = Proc.new do |listen|
      next unless listen.host.deployed.include?(@wielder)
      area = listen.subscriber.wielder.current_hex.get_area_hexes(1)
      for h in area[0]
        next unless h.battler
        shield = Shield_Stocked.new(1, [Damage_Ability])
        hbuff = Buff.new(self, h.battler, [shield])
        # Proc that denies non-damaging spells & dispels the buff
        # Triggers when targetted by an enemy
        juke = Proc.new do |listen, targeter, target_info|
          target_info[0].delete(listen.host.current_hex)
          for d in target_info[1]
            d[:hexes].delete(listen.host.current_hex)
            d[:targets].delete(listen.host.current_hex) if d[:targets]
          end
          listen.subscriber.clear_buff
        end
        hbuff.gen_subscription_to(h.battler, :BeingTargetedEnemy, juke)
        ssprite = new_animation_sprite
        ssprite.bitmap = RPG::Cache.icon("Ability/Helene_shield.png")
        ssprite.z = h.battler.sprite.z+1
        ssprite.add_stick_to(h.battler.sprite)
        hbuff.board_sprite = ssprite
      end
    end
    @equip_listen = gen_subscription_to(@wielder.owner, :Deployed, shields_up)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_BartensJournal)