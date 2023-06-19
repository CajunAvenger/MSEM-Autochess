class Menna < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Menna",
      :display    => "Menna al-Mejat",
      :cost       => 3,
      :synergy    => [:AERIAL, :CONVERGENT, :DRACONIC],
      :range      => [1, 2, 2],
      :power      => [30, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [950, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:aggro, 2]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
  def attack_sprite(attack_keys)
    return "Weapon/rsword.png"
  end
  
end

module AbilityLibrary
  def ability_script_menna(target_info, mana_cost=@ability_cost)
    targ = target_info[0][0].battler
    return unless targ
    abil_damage = 50 * mana_amp
    damage_event = Damage_Ability.new(self, targ, abil_damage)
    damage_event.execute = 0.2
    
    spr = new_animation_sprite
    spr.bitmap = RPG::Cache.icon("Ability/rmeteor.png")
    spr.center_on(@sprite)
    spr.angle = angle_of(@sprite, targ.sprite)
    spr.z = @sprite.z+30
    spr.opacity = 200
    spr.add_slide_to(targ.sprite, 0.4*fps)
    spr.add_fade_to(255, 0.4*fps, 1)
    spr.add_damage(damage_event, "enemy")
    spr.add_dispose
  end
end

register_planeswalker(Menna)