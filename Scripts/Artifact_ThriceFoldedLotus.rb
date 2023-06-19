class Artifact_ThriceFoldedLotus < Artifact
  def self.get_base_stats
    return {
      :name       => "Thrice-Folded Lotus",
      :description => "Grants huge amounts of mana amp, and deals damage " +
        "to all nearby enemies on spellcast.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:MANA_AMP, 100]]
      ],
      :back   => [:UNIQUE]
    }
  end
  
  def self.get_description
    return [
      "Grants huge amounts of mana amp,",
      "and deals damage to all nearby", 
      "enemies on spellcast."
    ]
  end
  
  def equip_to(target)
    super
    bolt = Proc.new do |listen, target_info, iter|
      area = listen.host.current_hex.get_area_hexes(1)
      tags = []
      for h in area[0]
        next unless h.battler
        next if h.battler.owner == @wielder.owner
        tags.push(h.battler)
      end
      d = Damage.new(@wielder, tags, 50*@wielder.mana_amp)
      f1 = new_animation_sprite
      f1.bitmap = RPG::Cache.icon("Ability/Artifact/Lotus_1.png")
      f1.z = @sprite.z + 40
      f1.center_on(@wielder.sprite)
      f1.add_fade_to(0, 0.6*@wielder.fps)
      f1.add_dispose
      
      f2 = new_animation_sprite
      f2.bitmap = RPG::Cache.icon("Ability/Artifact/Lotus_2.png")
      f2.center_on(@wielder.sprite)
      f2.z = @sprite.z + 39
      f2.opacity = 0
      f2.add_wait(0.2*@wielder.fps)
      f2.add_fade_to(255, 1)
      f2.add_fade_to(0, 0.4*@wielder.fps)
      f2.add_dispose
      
      f3 = new_animation_sprite
      f3.bitmap = RPG::Cache.icon("Ability/Artifact/Lotus_3.png")
      f3.center_on(@wielder.sprite)
      f3.z = @sprite.z + 38
      f3.opacity = 0
      f3.add_wait(0.4*@wielder.fps)
      f3.add_fade_to(255, 1)
      f3.add_damage(d, "locked")
      f3.add_fade_to(0, 0.2*@wielder.fps)
      f3.add_dispose
    end
    @bolt_listen = gen_subscription_to(@wielder, :UsedAbility, bolt)
  end
  
  def unequip_from(dont_trigger = false)
    super
    @bolt_listen.clear_listener
  end
  
end
register_artifact(Artifact_ThriceFoldedLotus)