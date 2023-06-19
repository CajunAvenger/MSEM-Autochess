class Sevid < Planeswalker
  def self.get_base_stats
    return {
      :name       => "Sevid",
      :display    => "Sevid Fese",
      :cost       => 1,
      :synergy    => [:THESPIAN, :SCOUT],
      :range      => 3,
      :power      => [40, 60, 90],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 20,
      :ward       => 0,
      :life       => [500, 900, 1620],
      :ability_cost => 70,
      :starting_mana => 20.0,
      :mana_cooldown => 1.0,
      :slow_start => 0,
      :pronoun    => "she/her"
    }
  end

#Sevid: adc caster hybrid like ez. decend damage, utility casting
#Spell: Scramble the Scouts: Sevid fires a warning shot into her target, dealing MS-[120/150/180]% power damage and
#applying a MS-[20/25/35]% haste debuff for 4 seconds. Any scouts in melee range with the target leap away.

  def self.ability_aim
    return [:aggro, 5]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
  def attack_sprite_file(attack_keys)
    base = "Weapon/gsword.png"
    ag = attack_keys[:aggro]
    unless @current_hex.get_neighbors.include?(ag.current_hex)
      base = "Weapon/grock.png"
    end
    return base
  end
  
end

module AbilityLibrary
  def ability_script_sevid(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    aggro = target_info[0][0].battler
    abil_damage = [1.2, 1.2, 1.5, 1.8][@level] * get_value(:POWER) * mana_amp
    abil_slow = [-0.2,  -0.2, -0.25, -0.3][@level] * mana_amp
    damage = Damage_Ability.new(self, aggro, abil_damage)
    inked = Proc.new do |target, amount|
      imp = Impact.new(:HASTE_MULTI, abil_slow)
      Debuff_Timed.new(self, target, imp, 4, "Scramble the Scouts")
      ns = target.current_hex.get_neighbors
      for n in ns
        ink = new_animation_sprite
        ink.bitmap = RPG::Cache.icon("Ability/Hexes/ink.png")
        ink.x = n.pixel_x
        ink.y = n.pixel_y
        ink.z = @sprite.z + 100
        ink.add_fade_to(0, fps)
        ink.add_dispose
        if n.battler && n.battler.owner == @owner && n.battler.synergies.include?(:SCOUT)
          dir = n.get_direction_to(target.current_hex)
          rev_dirs = reverse_directions(dir)
          for d in rev_dirs
            hex = n.hex_in_direction(d)
            next unless hex
            break if hex.set_battler(n.battler)
          end
        end
      end
    end
    damage.add_proc(inked)
    pen = new_animation_sprite
    pen.bitmap = RPG::Cache.icon("Ability/pen.png")
    pen.center_on(@sprite)
    pen.angle = angle_of(@sprite, aggro.sprite)
    pen.z = @sprite.z + 35
    pen.add_slide_to(aggro.sprite, 0.3*fps)
    pen.add_damage(damage, "enemy")
    pen.add_dispose
  end
end

register_planeswalker(Sevid)
=begin
class Sevid < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Sevid",
      :cost       => 1,
      :synergy    => [:THESPIAN, :SCOUT],
      :range      => [3, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40]
    }
  end
  
  def self.ability_aim
    return [:closest_enemy, 1]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
  def attack_sprite_file(attack_keys)
    base = "Weapon/gsword.png"
    ag = attack_keys[:aggro]
    unless @current_hex.get_neighbors.include?(ag.current_hex)
      base = "Weapon/grock.png"
    end
    return base
  end
  
end

module AbilityLibrary
  def ability_script_sevid(target_info, mana_cost=@ability_cost)
    aggro = target_info[0][0].battler
    Debuff.new(self, aggro, Impact.new(:HASTE_MULTI, -0.33))
    map = new_animation_sprite
    map.bitmap = RPG::Cache.icon("Ability/map.png")
    map.center_on(@sprite)
    map.z = @sprite.z + 20
    map.add_slide_to(aggro.sprite, 0.4*fps)
    map.add_dispose
    dir = @current_hex.get_direction_to(aggro.current_hex)
    jump_dirs = reverse_directions(dir)
    for d in jump_dirs
      jump_hex = @current_hex.hex_in_direction(d)
      next unless jump_hex
      break if jump_hex.set_battler(self)
    end
  end
end

register_planeswalker(Sevid)
=end