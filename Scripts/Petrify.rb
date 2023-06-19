class Petrify < Aura
  
  def self.get_base_stats
    return {
      :name => "Petrify",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Multistruck enemies are turned",
      "to stone briefly, and take extra",
      "damage from the next attack.",
      "Gain a Shimmerhide Boots."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    @owner.give_artifact(Artifact_ShimmerhideBoots.new)

    afraid = Proc.new do |target, amount, damage_event|
      imps = [
        Impact.new(:STUN, 1),
        Impact.new(:PETRIFIED, 1)
      ]
      p = Debuff_Timed.new(damage_event.source, target, imps, 0.2)
      stone_spr = new_animation_sprite
      stone_spr.bitmap = RPG::Cache.icon("Ability/Hexes/stone.png")
      stone_spr.z = target.sprite.z + 1
      stone_spr.opacity = 200
      stone_spr.add_stick_to(target.sprite)
      p.board_sprite = stone_spr
    end
      
    petrified = Proc.new do |listen, unit, attack_keys, i|
      next unless i == 1
      attack_keys[:extra_p] += 20
      attack_keys[:procs].push(afraid)
    end
    gen_subscription_to(@owner, :Attacked, petrified)
    
  end

end

register_aura(CurseOfThePetrified)