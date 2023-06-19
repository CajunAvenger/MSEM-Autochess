class Edarna < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Edarna",
      :cost       => 3,
      :synergy    => [:NECROMANCER, :AERIAL, :ALARA],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :ability_cost => -500,
      :pronoun    => "she/her"
    }
  end
  
  def attack_sprite_file(attack_keys)
    file = "Weapon/Edarna/claws"
    if attack_keys[:aggro].current_hex.pixel_x > @current_hex.pixel_x
      return file + "_r.png"
    end
    return file + "_l.png"
  end

  def owner=(player)
    @owner = player
    # proc for the first time Edarna dies each match
    reborn = Proc.new do |listen, *args|
      edarna = listen.subscriber
      abil_damage = 100 * edarna.mana_amp
      mana_scale = edarna.mana / 500
      area = edarna.current_hex.get_area_hexes(3)

      # hold distances to delay the flames
      hexes = {}
      for d in area[1]
        for h in d[:hexes]
          hexes[h.id] = d[:dist].to_f / 10
        end
      end
      
      # calc the revival hp
      ml = edarna.get_value(:MAX_LIFE)
      @current_damage = ml-1
      new_hp = mana_scale * ml
      # root, cloak, and invuln Edarna until the revive starts
      imps = [
        Impact.new(:CLOAK, 1),
        Impact.new(:INVULNERABLE, 1),
        Impact.new(:Casting, 1)
      ]
      ebuff = Buff_Timed.new(self, self, imps, 0.4)
      # proc to apply the heal once Edarna has "died"
      heal = Proc.new do |listen|
        edarna = listen.subscriber
        edarna.apply_heal(Impact.new(:HEALING, new_hp))
        edarna.mana = 0
        edarna.update_mana
        edarna.ability_cost = 0
      end
      gen_subscription_to(ebuff, :Expired, heal)
      # fade Edarna out like she died, then bring her back
      sc = @sprite.add_schedule
      @sprite.add_fade_to(0, 0.4*fps, sc)
      @sprite.add_fade_to(255, 0.4*fps, sc)
      # apply the fire aoe
      for h in area[0]
        next if h == @current_hex
        fire_hex = new_animation_sprite
        fire_hex.bitmap = RPG::Cache.icon("Ability/edarna_fire.png")
        fire_hex.opacity = 0
        fire_hex.x = h.pixel_x
        fire_hex.y = h.pixel_y
        fire_hex.z = @sprite.z+30
        wait_sec = 0.4 + hexes[h.id]
        fire_hex.add_wait(wait_sec*fps)
        fire_hex.add_fade_to(255, 0.2*fps)
        fire_hex.add_damage(Damage_Ability.new(self, nil, abil_damage), "enemy")
        fire_hex.add_fade_to(0, 0.2*fps)
        fire_hex.add_dispose
      end
      # emit Died for Necro synergy and whatever else
      edarna.emit(:Died, edarna, edarna.current_hex, nil)
    end
    
    # every match, reset the revive proc if Edarna is in
    ashes = Proc.new do |listen|
      next unless listen.host.deployed.include?(self)
      l = gen_subscription_to(self, :Dying, reborn)
      l.fragile = true
    end
    gen_subscription_to(@owner, :Deployed, ashes)
    
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
end

module AbilityLibrary
  def ability_script_edarna(target_info, mana_cost=@ability_cost)
    # here so game doesn't crash when we try to force Edarna to cast
  end
end

register_planeswalker(Edarna)