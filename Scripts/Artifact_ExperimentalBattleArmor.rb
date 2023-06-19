class Artifact_ExperimentalBattleArmor < Artifact

  def self.get_base_stats
    return {
      :name       => "Experimental Battle Armor",
      :description => "Grants multistrike chance and toughness. " + 
        "Attacks have a chance to knockback the target.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Armor"],
      :impacts    => [
        [Impact, [:MULTI, 10]],
        [Impact, [:TOUGHNESS, 10]]
      ],
      :components => ["Flintlock Pistol", "Burnished Plate"],
      :back   => [:MULTI, :TOUGHNESS]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants multistrike chance and",
      "toughness. Attacks have a chance",
      "to knockback the target."
    ]
  end
  
  def equip_to(target)
    super
    add_knockback = Proc.new do |listen, attack_keys|
      next unless rand(100) < 25
      dir = attack_keys[:aggro].current_hex.get_direction_to(listen.host.current_hex)
      knockback = Proc.new do |target, amount|
        dirs = reverse_directions(dir)
        for d in dirs
          hb = target.current_hex.hex_in_direction(d)
          next unless hb
          break if hb.set_battler(target)
        end
      end
      attack_keys[:procs].push(knockback)
    end
    @equip_listen = gen_subscription_to(@wielder, :Attacking, add_knockback)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_ExperimentalBattleArmor)