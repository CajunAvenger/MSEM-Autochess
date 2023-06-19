class Rain < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Rain",
      :display    => "Rain Zai",
      :cost       => 1,
      :synergy    => [:COMMANDER, :NECROMANCER],
      :range      => 2,
      :power      => [40, 60, 90],
      :multi      => 10,
      :haste      => 0.6,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 40,
      :ward       => 10,
      :life       => [700, 1260, 2270],
      :ability_cost => 70,
      :starting_mana => 20.0,
      :mana_cooldown => 1.0,
      :slow_start => 0,
      :pronoun    => "he/him"
    }
  end

#Rain Zai: synergy piece for commander necro build, good off tank with burst damage, made to sit behind front lines.
#Spell: Rend. Rain Zai tears a piece off his enemy's soul, dealing MS-[200/250/300] damage and healing himself or his
#lowest health ally half that. If a skeleton is nearby, he sacrifices it to instead deal MS-[1000/1500/2000] damage.

  def self.ability_aim
    return [:aggro, 1]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/gray.png"
  end
  
end

module AbilityLibrary
  def ability_script_rain(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    target = target_info[0][0].battler
    sac = false
    abil_damage = [200, 200, 250, 300]
    area = @current_hex.get_area_hexes(2)
    for h in area[0]
      next unless h.battler
      next unless h.controller == @owner
      next unless h.battler.is_a?(Necromancer_Skeleton)
      @owner.sacrifice(h.battler)
      abil_damage = [1000, 1000, 1500, 2000]
      break
    end
    abil_damage = abil_damage[@level] * mana_amp
    
    snek = new_animation_sprite
    dir = @current_hex.get_direction_to(target.current_hex)
    snek.bitmap = RPG::Cache.icon("Ability/Rain/snake" + dir_to_tag(dir) + ".png")
    snek.x = @sprite.x - 64
    snek.y = @sprite.y - 50
    snek.z = @sprite.z + 22
    snek.add_fade_to(0, 0.6*fps)
    snek.add_dispose
    distribute = Proc.new do |target, amount|
      assist = 0
      life = amount/2
      if life > self.current_damage
        assist = life = self.current_damage
        life -= assist
      end
      self.apply_heal(Heal.new(life))
      ally = [nil, 999999]
      for u in self.owner.deployed
        al_life = u.get_life
        ally = [u, al_life] if al_life < ally[1]
      end
      next unless ally[0]
      ally[0].apply_heal(Heal.new(assist))
    end
    d = Damage_Ability.new(self, target, abil_damage)
    d.add_proc(distribute)
    d.resolve
  end
end

register_planeswalker(Rain)
