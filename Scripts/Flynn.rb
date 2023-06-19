class Flynn < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Flynn",
      :display    => "Flynn Skara",
      :cost       => 3,
      :synergy    => [:SISTERS, :DRACONIC, :AERIAL],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :ability_cost => 30,
      :pronoun    => "she/her"
    }
  end

  def self.ability_area
    return [:cone, 2]
  end
  
  def self.ability_target
    return [:aggro, 2]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/ur_fire.png"
  end
  
end

module AbilityLibrary
  
  def ability_script_flynn(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    targets = []
    dir = target_info[3]
    angler = {
      :bottom_left => 0,
      :bottom => 45,
      :bottom_right => 90,
      :right => 135,
      :top_right => 180,
      :top => 225,
      :top_left => 270,
      :left => 315
    }
    for targetHex in target_info[0]
      next unless targetHex.battler
      next unless targetHex.battler.owner != @owner
      targets.push(targetHex.battler)
    end
    sprite = $scene.spriteset.add_anim_to_port(Sprite_Chess)
    #sprite.opacity = 0
    sprite.bitmap = RPG::Cache.icon("Ability/Sister/flynn_fire.png")
    sprite.ox = 121
    sprite.oy = 36
    sprite.x = @current_hex.center_x
    sprite.y = @current_hex.center_y
    sprite.z = 9001
    sprite.angle = angler[dir]
    sprite.add_wait(0.4*fps)
    sprite.add_damage(Damage_Ability.new(self, targets, 40*mana_amp), "locked")
    sprite.add_wait(0.4*fps)
    sprite.add_fade_to(0, 0.8*fps)
    sprite.add_dispose(0)
    sprite.add_scan(40, 0.5*fps, 0, 1)
    efs = []
    efs.push(Impact.new(:MULTI,90))
    efs.push(Impact.new(:BonusAirTime,  1))
    Buff_Timed.new(self, self, efs, 3, "Transcend")
  end
end

register_planeswalker(Flynn)