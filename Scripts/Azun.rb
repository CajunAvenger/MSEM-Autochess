class Azun < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Azun",
      :cost       => 1,
      :synergy    => [:INVESTIGATOR, :GUNSLINGER],
      :range      => 3,
      :power      => [40, 60, 90],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 20,
      :ward       => 0,
      :life       => [500, 900, 1620],
      :ability_cost => 90,
      :starting_mana => 50.0,
      :mana_cooldown => 1.0,
      :slow_start => 0,
      :pronoun    => "he/him"
    }
  end
  
#Azun: supporting gunslinger for activating synergy, aoe stun probably good but not enough selfbuff to carry
#Spell: Slinger's Showdown. Azun fills the air with aetherite bullets, dealing MS-[50/100/150] damage to all enemies in a 
#large cone and stunning for F-[0.5/0.75/1] seconds.

def self.ability_aim
    return [:aggro, 4]
  end
  
  def self.ability_area
    return [:cone, 4]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/Azun/bullet.png"
  end
  
  def six_sprite_file(attack_keys)
    return "Weapon/Azun/six.png"
  end
  
end

module AbilityLibrary
  def ability_script_azun(target_info, mana_cost=@ability_cost)
    console.log("casting")
    targs = []
    angler = {
      :top => 0,
      :bottom => 180,
      :right => -90,
      :left => 90,
      :top_right => -63,
      :top_left => 63,
      :bottom_right => -117,
      :bottom_left => 117
    }
    angle = angler[target_info[3]]

    for h in target_info[0]
      next unless h.battler
      next unless h.controller != @owner
      targs.push(h.battler)
    end
    abil_damage = [50, 50, 100, 150][@level] * mana_amp
    dura = [0.5, 0.5, 0.75, 1][@level]
    damage_event = Damage_Ability.new(self, targs, abil_damage)
    quell = Proc.new do |target, amount|
      Buff_Timed.new(self, target, Impact.new(:STUN, 1), dura, "Quelled")
    end
    damage_event.add_proc(quell)
    
    bullet = new_animation_sprite
    bullet.bitmap = RPG::Cache.icon("Ability/Gunslinger/quell_bullet.png")
    bullet.ox = bullet.center_x
    bullet.oy = bullet.center_y
    bullet.x = @sprite.midpoint_x
    bullet.y = @sprite.midpoint_y
    bullet.z = @sprite.z + 30
    bullet.angle = angle
    bullet.add_translate(-96*Math.sin(to_radians(angle)), -96*Math.cos(to_radians(angle)), 0.3*fps)
    bullet.add_damage(damage_event, "locked")
    bullet.add_fade_to(0, 0.2*fps)
    bullet.add_dispose
    
    waves = new_animation_sprite
    waves.bitmap = RPG::Cache.icon("Ability/Gunslinger/quell_wave.png")
    waves.ox = 124
    waves.oy = 75
    waves.x = @sprite.midpoint_x - 128*Math.sin(to_radians(angle))
    waves.y = @sprite.midpoint_y - 128*Math.cos(to_radians(angle))
    waves.z = @sprite.z + 30
    waves.opacity = 0
    waves.angle = angle
    waves.add_wait(0.3*fps)
    waves.add_fade_to(255, 0.1*fps)
    waves.add_fade_to(0, 0.2*fps)
    waves.add_dispose
  end
end

register_planeswalker(Azun)