class Alia < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Alia",
      :cost       => 3,
      :synergy    => [:AKIEVA, :MORNINGLIGHT, :CLERIC],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => 100,
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [500, 20, 40],
      :starting_mana => 70.0,
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:aggro, 4]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
end

module AbilityLibrary
  def ability_script_alia(target_info, mana_cost=@ability_cost)
    primary = target_info[0][0]
    return unless primary
    abil_damage = 40 * mana_amp + (get_value(:LIFE) / 500)
    main_spr = new_animation_sprite
    main_spr.bitmap = RPG::Cache.icon("Ability/shard.png")
    main_spr.center_on(@sprite)
    main_spr.angle = angle_of(@sprite, primary.battler.sprite)
    main_spr.z = @sprite.z + 10
    main_spr.add_slide_to(primary.battler.sprite, 0.4*fps)
    main_spr.add_damage(Damage_Ability.new(self, primary.battler, abil_damage))
    main_spr.add_dispose()
    surround = primary.get_area_hexes(1)

    for h in surround[1][1][:hexes]
      sub_spr = new_animation_sprite
      sub_spr.bitmap = RPG::Cache.icon("Ability/shard.png")
      sub_spr.center_on(primary.battler.sprite)
      sub_spr.z = primary.battler.sprite.z + 10
      sub_spr.visible = false
      sub_spr.angle = angle_of(sub_spr, h)
      sub_spr.add_wait(0.4*fps-1)
      sub_spr.switch_visible()
      if h.battler && h.controller != @owner && can_target?(h)
        sub_spr.add_slide_to(h.battler.sprite, 0.5*fps)
        sub_spr.add_damage(Damage_Ability.new(self, primary.battler, abil_damage))
      else
        sub_spr.add_move_to(h.center_x, h.center_y, 0.5*fps)
      end
      sub_spr.add_dispose()
    end
  end
end

register_planeswalker(Alia)