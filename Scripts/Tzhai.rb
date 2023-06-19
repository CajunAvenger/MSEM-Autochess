class Tzhai < Planeswalker
  def self.get_base_stats
    return {
      :name       => "Tzhai",
      :cost       => 4,
      :synergy    => [:ELDER, :COMMANDER, :SHAHARAZAD],
      :range      => [2, 1, 1],
      :power      => [70, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [0.7, 20, 40],
      :mana_amp   => 100,
      :archive    => [10, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [100, 20, 40],
      :pronoun    => "he/him"
    }
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/msword.png"
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:all, 0]
  end
  
end

module AbilityLibrary
  
  def ability_script_tzhai(target_info, mana_cost=@ability_cost)
    # determine base damage
    abil_damage = 50*mana_amp
    # for each hex that matches our ability_area
    for h in target_info[0] do
      # skip hexes that include allies
      next if h.controller == @owner
      # create a sun sprite centered on Tzhai
      sprite = new_animation_sprite()
      sprite.bitmap = RPG::Cache.icon("Ability/msun.png")
      sprite.center_on(@sprite)
      sprite.z = 6000
      # move to center of target hex
      sprite.add_move_to(h.midpoint_x, h.midpoint_y, 0.4*fps)
      # deal damage; Ability damage by self to h.battler for abil_damage
      sprite.add_damage(Damage_Ability.new(self, h.battler, abil_damage), "locked")
      # hold the animation for a bit
      sprite.add_wait(0.8*fps)
      # return to Tzhai, use slide instead of move for sprite targets
      sprite.add_slide_to(@sprite, 0.4*fps, 32, 32)
      # then delete the sprite
      sprite.add_dispose(0)
      # add second schedule and have the sun spin during the entire animation
      sprite.add_spin(7, 0, 1)
    end
    gen_invulnerable_buff(self, self, 2)
  end
  
end

register_planeswalker(Tzhai)