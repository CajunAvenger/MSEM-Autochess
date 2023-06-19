class Tara < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Tara",
      :cost       => 1,
      :synergy    => [:INVESTIGATOR, :SCOUT],
      :range      => 3,
      :power      => [40, 60, 90],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 20,
      :ward       => 0,
      :life       => [500, 900, 1620],
      :ability_cost => 30,
      :starting_mana => 0.0,
      :mana_cooldown => 1.0,
      :slow_start => 0,
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:aggro, 5]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/whirl.png"
  end
end

module AbilityLibrary
  def ability_script_tara(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    targ = target_info[0][0].battler
    abil_damage = [100, 100, 200, 300][@level] * mana_amp
    sand = new_animation_sprite
    sand.bitmap = RPG::Cache.icon("Ability/sandstorm.png")
    sand.center_on(@sprite)
    sand.angle = angle_of(@sprite, targ.sprite)
    sand.z = @sprite.z + 25
    sand.add_slide_to(targ.sprite, 0.3*fps)
    sand.add_damage(Damage_Ability.new(self, targ, abil_damage), "locked")
    sand.add_spin(36, 0.3*fps)
    sand.add_dispose
    Buff.new(self, self, Shield.new(abil_damage))
  end
end

register_planeswalker(Tara)