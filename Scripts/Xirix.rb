class Xirix < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Xirix",
      :cost       => 3,
      :synergy    => [:CHRONOMANCER, :ASSASSIN],
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
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
end

module AbilityLibrary
  def ability_script_xirix(target_info, mana_cost=@ability_cost)
    # Summon two short-lived duplicates of Xirix attacking different targets.
    # When the duration runs out, the one with the highest remaining life stays
    # in play, and the other two vanish in explosions of mana-scaking damage.
    xs = [Xirix.new(@owner, @level), Xirix.new(@owner, @level)]
    for x in xs
      x.temp = true
      for id, b in @buffs
        x.add_buff(b.create_clone(x))
      end
      for a in artifacts
        x.give_artifact(a.create_clone())
      end
      x.current_damage = @current_damage
      x.stacks = @stacks
      x.ability_cost = @ability_cost
      x.mana_cooldown = @mana_cooldown
      @owner.give_unit(x, @owner.opponent.deployed[rand(@owner.opponent.deployed.length)])
    end
    xs.push(self)
    thin_the_herd = Proc.new do |frames|
      final_xirix = self
      # figure out where final xirix is standing
      for x in xs
        next if x == self
        self.damage_dealt += x.damage_dealt
        self.damage_taken += x.damage_taken
        self.damage_healed += x.damage_healed
        next if x.dead
        final_xirix = x if x.get_life > final_xirix.get_life
      end
      # other two that are alive smoke bomb
      for x in xs
        next if x.dead
        next if x == final_xirix
        tags = []
        for h in x.current_hex.get_neighbors
          smoke = new_animation_sprite
          smoke.bitmap = RPG::Cache.icon("Ability/smoke.png")
          smoke.center_on(x.sprite)
          smoke.angle = angle_of(x.sprite, h)
          smoke.z = 6030
          smoke.add_move_to(h.center_x, h.center_y, 0.3*fps)
          smoke.add_damage(Damage_Ability.new(x, nil, 100*x.mana_amp), "enemy")
          smoke.add_fade_to(0, 0.5*fps, 1)
          smoke.add_dispose(1)
        end
        x.sprite.opacity = 0
      end
      final_hex = final_xirix.current_hex
      # sac the tokens
      for x in xs
        @owner.sacrifice(x) unless x == self
      end
      # secretly move the real xirix to where final xirix is
      if final_xirix != self
        final_hex.battler = self
        self.current_hex = final_hex
        self.sprite.add_snap(final_hex.pixel_x, final_hex.pixel_y, self.sprite.add_schedule())
        self.sprite.vis(true)
        self.sprite.opacity = 255
      end
    end
    $timer.add_framer(3*fps, thin_the_herd)
  end
end

register_planeswalker(Xirix)
