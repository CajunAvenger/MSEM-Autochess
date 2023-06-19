class Bahum < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Bahum",
      :cost       => 2,
      :synergy    => [:INVESTIGATOR, :CLERIC],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "they/them"
    }
  end
  
  def self.ability_aim
    return [:aggro, 2]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/staff.png"
  end
  
end

module AbilityLibrary
  def ability_script_bahum(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    targ = target_info[0][0].battler
    abil_damage = 100 * mana_amp
    damage = Damage_Ability.new(self, targ, abil_damage)
    dir = targ.current_hex.get_direction_to(@current_hex)
    knockback = Proc.new do |target, amount|
      dirs = reverse_directions(dir)
      for d in dirs
        hb = target.current_hex.hex_in_direction(d)
        next unless hb
        break if hb.set_battler(target)
      end
    end
    damage.add_proc(knockback)
    ghand = new_animation_sprite
    ghand.z = @sprite.z + 30
    ghand.bitmap = RPG::Cache.icon("Ability/ghand.png")
    ghand.center_on(@sprite)
    ghand.add_slide_to(targ.sprite, 0.3*fps)
    ghand.add_damage(damage, "enemy")
    ghand.add_fade_to(0, 0.2*fps)
    ghand.add_dispose
    
    
  end
end

register_planeswalker(Bahum)
