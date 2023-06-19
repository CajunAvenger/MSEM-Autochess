class Malextros < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Malextros",
      :cost       => 5,
      :synergy    => [:COMMANDER, :NECROMANCER],
      :range      => [1, 2, 2],
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
    return "Weapon/bsword.png"
  end
  
end

module AbilityLibrary
  def ability_script_malextros(target_info, mana_cost=@ability_cost)
    dura = 4
    death_scale = 1 + (@owner.match.counters[:deaths].to_f / 4)
    scale = 100.0 * mana_amp * death_scale
    imps = [
      Impact.new(:POWER, scale),
      Impact.new(:TOUGHNESS, scale)
    ]
    mbuff = Buff_Timed.new(self, self, imps, dura)
    skull = new_animation_sprite
    skull.bitmap = RPG::Cache.icon("Ability/tiny_skull.png")
    skull.z = @sprite.z + 30
    skull.add_orbit(@sprite, 32, 32, 0)
    mbuff.board_sprite = skull
  end
end

register_planeswalker(Malextros)
