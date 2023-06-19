class Heddwyn < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Heddwyn",
      :cost       => 3,
      :synergy    => [:GUNSLINGER, :INVESTIGATOR],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [100, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [300, 20, 40],
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:aggro, 3]
  end
  
  def self.ability_area
    return [:line, 3]
  end

  def attack_sprite_file(attack_keys)
    return "Weapon/Heddwyn/bullet.png"
  end
  
  def six_sprite_file(attack_keys)
    return "Weapon/Heddwyn/six.png"
  end

end

module AbilityLibrary
  #Stun enemies in a short line for a mana-scaling duration.
  #Heddwyn deals % increased damage to enemies stunned this way.
  def ability_script_heddwyn(target_info, mana_cost=@ability_cost)
    stun_dur = 2 * mana_amp
    for h in target_info[0]
      next unless h.battler
      next if h.controller == @owner
      bonus_damage = Proc.new do |listen, damage_event|
        curr = damage_event.damage_to(h.battler)
        damage_event.increase_to(h.battler, 0.4*curr)
      end
      sbuff = Debuff_Timed.new(self, h.battler, Impact.new(:STUN, 1), stun_dur, "Heddwyn Stun")
      l = gen_subscription_to(h.battler, :IncomingDamage, bonus_damage)
      stop_listening = Proc.new do |listen|
        l.clear_listener
      end
      l2 = gen_subscription_to(sbuff, :Expired, stop_listening)
      l2.fragile = true
    end
    hand = new_animation_sprite
    hand.bitmap = RPG::Cache.icon("Ability/Gunslinger/uhand.png")
    hand.x = @sprite.x
    hand.y = @sprite.y
    hand.z = @sprite.z + 20
    hand.add_move_to(target_info[0].last.pixel_x, target_info[0].last.pixel_y, 0.5*fps)
    hand.add_dispose
  end
end

register_planeswalker(Heddwyn)