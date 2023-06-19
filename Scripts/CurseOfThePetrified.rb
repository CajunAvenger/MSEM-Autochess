class CurseOfThePetrified < Aura
  
  def self.get_base_stats
    return {
      :name => "Curse of the Petrified",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Stunned enemies are turned",
      "to stone, and take extra",
      "damage from the next attack.",
      "Gain a Dominion Crown."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    
    @owner.give_artifact(Artifact_DominionCrown.new)

    petrify = Proc.new do |listen, buffer, buff, *args|
      valid = false
      for i in buff.impacts
        valid = true if i.id == :STUN
      end
      next unless valid
      imps = [
        Impact.new(:PETRIFIED, 1),
        Impact.new(:TOUGHNESS_MULTI, -0.33)
      ]
      stone_spr = new_animation_sprite
      stone_spr.bitmap = RPG::Cache.icon("Ability/Hexes/stone.png")
      stone_spr.z = buff.target.sprite.z + 1
      stone_spr.opacity = 200
      stone_spr.add_stick_to(buff.target.sprite)
      p = Debuff_Timed.new(self, buff.target, imps, buff.duration/$frames_per_second)
      p.board_sprite = stone_spr
      exp = Proc.new do |listen, *args|
        listen.subscriber.clear_buff
      end
      p.gen_subscription_to(buff.target, :Damaged, exp)
    end
    gen_subscription_to(@owner, :Buffing, petrify)
    
  end

end

register_aura(CurseOfThePetrified)