class Azamir < Planeswalker
  def self.get_base_stats
    return {
      :name       => "Azamir",
      :cost       => 5,
      :synergy    => [:ELDER, :BARD, :SHAHARAZAD],
      :range      => [1, 1, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => 100,
      :archive    => [100, 20, 40],
      :toughness  => [100, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [800, 20, 40],
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:custom_ward, 1]
  end
  
  def self.ability_area
    return [:area, 2]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/wray.png"
  end
  
end

module AbilityLibrary
  
  def aim_script_azamir(range)
    hash = {:hex => nil, :comp => nil}
    for u in @owner.opponent.deployed
      next unless can_target?(u.current_hex)
      high_life(u.current_hex, hash)
    end
    return @current_hex unless hash[:hex]
    return hash[:hex]
  end

  def ability_script_azamir(target_info, mana_cost=@ability_cost)
    base_damage = 70 * mana_amp
    base_stun = 2
    pers = [1, 0.5, 0.25]
    prim = (target_info[1][0][:hexes][0] || nil)
    return unless prim
    sprite = new_animation_sprite()
    sprite.x = prim.pixel_x
    sprite.y = prim.pixel_y
    sprite.z = 6010
    sprite.bitmap = RPG::Cache.icon("Ability/Azamir/csmash.png")
    sprite.add_fade_to(0, fps)
    sprite.add_dispose(0)
    
    sprite2 = new_animation_sprite()
    sprite2.x = prim.pixel_x - $hex_width
    sprite2.y = prim.pixel_y - $hex_height
    sprite2.z = 6009
    sprite2.opacity = 0
    sprite2.bitmap = RPG::Cache.icon("Ability/Azamir/csmash_mid.png")
    sprite2.add_wait(0.2*fps)
    sprite2.add_fade_to(200, 1)
    sprite2.add_fade_to(0, fps)
    sprite2.add_dispose(0)
    
    sprite3 = new_animation_sprite()
    sprite3.x = prim.pixel_x - 1.5*$hex_width
    sprite3.y = prim.pixel_y - 1.5*$hex_height
    sprite3.z = 6008
    sprite3.opacity = 0
    sprite3.add_wait(0.4*fps)
    sprite3.add_fade_to(150, 1)
    sprite3.bitmap = RPG::Cache.icon("Ability/Azamir/csmash_huge.png")
    sprite3.add_fade_to(0, fps)
    sprite3.add_dispose(0)
    
    pulls = []
    for range_ob in target_info[1]
      dist = range_ob[:dist]
      hexes = range_ob[:hexes]
      dist_damage = base_damage * pers[dist]
      stun_dura = base_stun * pers[dist]
      for hex in hexes
        next unless hex.battler
        next if hex.controller == @owner
        Damage_Ability.new(self, hex.battler, dist_damage).resolve()
        ef = Impact.new(:STUN, 1)
        Debuff_Timed.new(self, hex.battler, ef, stun_dura)
        if prim && dist == 2
          dir = hex.get_direction_to(prim)
          pull = hex.hex_in_direction(dir)
          pulls.push([pull, hex.battler])
        end
      end
    end
    for p in pulls
      p[0].set_battler(p[1])
    end
  end

end

register_planeswalker(Azamir)