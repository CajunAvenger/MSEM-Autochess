class Arina < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Arina",
      :display    => "Arina Nisita",
      :cost       => 2,
      :synergy    => [:ASSASSIN, :WIZARD],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:dash, 5]
  end
  
  def self.ability_area
    return [:dash, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/usword.png"
  end
  
end

module AbilityLibrary
# Dash to an enemy and deal mana-scaling damage, and execute them if below % health.
  def ability_script_arina(target_info, mana_cost=@ability_cost)
    target_hex = target_info[0][0]
    return unless target_hex
    end_hex = target_info[2]
    return if end_hex.battler
    start_hex = @current_hex
    
    @sprite.add_fade_to(0, 1)
    end_hex.set_battler(self)
    @sprite.add_wait(0.4*fps)
    @sprite.add_fade_to(255, 1)
    # cloak and root for the duration
    imps = [
      Impact.new(:CLOAK, 1),
      Impact.new(:Casting, 1)
    ]
    Buff_Timed.new(self, self, imps, 0.8)
    abil_damage = 50 * mana_amp
    damage_event = Damage_Ability.new(self, target_hex.battler, abil_damage)
    damage_event.execute = 0.2

    dir = @current_hex.get_direction_to(target_hex)
    blink_hex = target_hex.hex_in_direction(dir)
    blink_hex = start_hex unless blink_hex
=begin
    clone_spr = new_animation_sprite
    clone_spr.bitmap = @sprite.bitmap
    clone_spr.x = blink_hex.pixel_x
    clone_spr.y = blink_hex.pixel_y
    clone_spr.z = target_hex.battler.sprite.z + 40
    clone_spr.add_fade_to(0, 0.1*fps)
    clone_spr.add_fade_to(255, 1)
    clone_spr.add_fade_to(0, 0.2*fps)
    clone_spr.add_fade_to(255, 1)
    clone_spr.add_fade_to(0, 0.2*fps)
    clone_spr.add_fade_to(255, 1)
    clone_spr.add_fade_to(0, 0.1*fps)
    clone_spr.add_dispose
    
    sword_spr = new_animation_sprite
    sword_spr.bitmap = build_attack_sprite(blink_hex.get_direction_to(target_hex))
    sword_spr.x = blink_hex.pixel_x
    sword_spr.y = blink_hex.pixel_y
    sword_spr.z = target_hex.battler.sprite.z + 39
    sword_spr.opacity = 0
    sword_spr.add_wait(0.4*fps)
    sword_spr.add_wait(0.6*fps, 1)
    sword_spr.add_fade_to(255, 1)
    sword_spr.add_slide_to(target_hex.battler.sprite, 0.2*fps)
    sword_spr.add_damage(damage_event, "locked")
    sword_spr.add_change_bitmap(build_attack_sprite(target_hex.get_direction_to(@current_hex)), 1)
    sword_spr.add_slide_to(@sprite, 0.2*fps)
    sword_spr.add_dispose
=end
    clone_spr = new_animation_sprite
    clone_spr.bitmap = @sprite.bitmap
    clone_spr.x = start_hex.pixel_x
    clone_spr.y = start_hex.pixel_y
    clone_spr.z = target_hex.battler.sprite.z + 40
    clone_spr.add_fade_to(0, 0.1*fps)
    clone_spr.add_fade_to(255, 1)
    clone_spr.add_fade_to(0, 0.2*fps)
    clone_spr.add_fade_to(255, 1)
    clone_spr.add_fade_to(0, 0.2*fps)
    clone_spr.add_fade_to(255, 1)
    clone_spr.add_fade_to(0, 0.1*fps)
    clone_spr.add_dispose
    
    sword_spr = new_animation_sprite
    sword_spr.bitmap = build_attack_sprite(nil)
    sword_spr.center_on(start_hex)
    sword_spr.angle = angle_of(start_hex, target_hex)
    sword_spr.z = target_hex.battler.sprite.z + 39
    sword_spr.opacity = 0
    sword_spr.add_wait(0.4*fps)
    sword_spr.add_wait(0.6*fps, 1)
    sword_spr.add_fade_to(255, 1)
    sword_spr.add_slide_to(target_hex.battler.sprite, 0.2*fps)
    sword_spr.add_damage(damage_event, "locked")
    sword_spr.add_slide_to(@sprite, 0.2*fps)
    sword_spr.add_dispose
  end
end

register_planeswalker(Arina)
