class Mafua < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Mafua",
      :cost       => 2,
      :synergy    => [:CAT, :WARRIOR],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/arrow.png"
  end
  
end

module AbilityLibrary
  def ability_script_mafua(target_info, mana_cost=@ability_cost)
    imps = [
      Impact.new(:INVULNERABLE, 1),
      Impact.new(:POWER, 50*mana_amp),
      Impact.new(:LIFESTEAL, 0.1*mana_amp)
    ]
    Buff_Timed.new(self, self, imps, 3)
    invuln_sprite = new_animation_sprite
    invuln_sprite.bitmap = RPG::Cache.icon("Ability/invuln.png")
    invuln_sprite.x = @sprite.x-26
    invuln_sprite.y = @sprite.y-26
    invuln_sprite.z = @sprite.z-1
    invuln_sprite.add_stick_to(@sprite, 3*fps, -26, -26)
    invuln_sprite.add_fading(255, 0, fps, 0, 1)
    invuln_sprite.add_dispose
  end
end

register_planeswalker(Mafua)