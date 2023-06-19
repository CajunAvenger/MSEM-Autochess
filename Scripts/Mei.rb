class Mei < Planeswalker
  def self.get_base_stats
    return {
      :name       => "Mei",
      :display    => "Mei Liva",
      :cost       => 3,
      :synergy    => [:SISTERS, :MIRRORWALKER, :THESPIAN],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [520, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/psword.png"
  end
  
end

module AbilityLibrary
  
  def ability_script_mei(target_info, mana_cost=@ability_cost)
    for targetHex in target_info[0]
      target = targetHex.battler
      tsprite = target.sprite

      for i in 0..6 do
        th = to_radians(360*i/5)
        sprite = $scene.spriteset.add_anim_to_port(Sprite_Chess)
        sprite.bitmap = RPG::Cache.icon("Ability/Sister/rteeth.png")
        sprite.x = tsprite.x
        sprite.y = tsprite.y + 32
        sprite.z = 6000
        sprite.visible = true
        sprite.add_orbit(tsprite, 32, 32, 1.5*fps, th)
        sprite.add_wiggles(3, 3, 0, 1)
        sprite.add_dispose(0)
        sprite.match_vis(tsprite, 2)
      end

      drain_buff = Debuff_Mindrip.new(self, target, [], 1.5, "Mindrip")
      drain_buff.trigger_effect()
      efs = [Impact.new(:STUN, 1)]
      efs.push(Impact.new(:ARCHIVE_MULTI, -0.5)) if @empowered.include?(:BindTheMind)
      stun_buff = Debuff_Timed.new(self, target, efs, 3, "Stunned")
      unstun = Proc.new do |listen, *args|
        listen.subscriber.clear_buff()
      end
      stun_buff.gen_subscription_to(self, :Damaged, unstun)
    end
  end
  
end

class Debuff_Mindrip < Debuff_Ticker
  def trigger_effect
    Damage_Ability.new(@source, @target, 1, 0, 1).resolve()
  end
end

register_planeswalker(Mei)