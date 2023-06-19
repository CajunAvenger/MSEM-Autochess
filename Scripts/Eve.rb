class Eve < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Eve",
      :cost       => 1,
      :synergy    => [:CAT, :ROGUE],
      :range      => [1, 2, 2],
      :power      => [30, 20, 40],
      :multi      => [20, 20, 40],
      :haste      => 1.8,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [150, 20, 40],
      :ability_cost => 60,
      :starting_mana => 60.0,
      :mana_cooldown => 1.0,
      :slow_start => 0.2,
      :pronoun    => "she/her"
    }
  end
  
  def attack_sprite_file(attack_keys)
    file = "Weapon/Eve/claws"
    if attack_keys[:aggro].current_hex.pixel_x > @current_hex.pixel_x
      return file + "_r.png"
    end
    return file + "_l.png"
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
end

module AbilityLibrary
  def ability_script_eve(target_info, mana_cost=@ability_cost)
    ow = Proc.new do |target, amount|
      Buff_Timed.new(self, target, Impact.new(:ARCHIVE_MULTI, -0.5), 5)
    end
    
    up_to_snuff = Proc.new do |listen, attack_keys|
      attack_keys[:extra_p] += 30 * mana_amp
      attack_keys[:procs].push(ow)
      cat_head = new_animation_sprite
      cat_head.bitmap = RPG::Cache.icon("Ability/eve_head.png")
      cat_head.x = attack_keys[:aggro].sprite.x
      cat_head.y = attack_keys[:aggro].sprite.y
      cat_head.z = attack_keys[:aggro].sprite.z+40
      cat_head.opacity = 0
      cat_head.add_fade_to(200, 0.6*fps)
      cat_head.add_dispose
    end
    
    l = gen_subscription_to(self, :Attacking, up_to_snuff)
    l.fragile = true
    try_attack(false)
  end
end

register_planeswalker(Eve)