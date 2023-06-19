class Daril < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Daril",
      :cost       => 1,
      :synergy    => [:ASSASSIN, :CHRONOMANCER],
      :range      => [2, 2, 2],
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
    return [:around_me, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/uray.png"
  end
  
end

module AbilityLibrary
  def ability_script_daril(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    @rooted += 1
    abil_damage = 100 * mana_amp
    strike = Proc.new do |*args|
      targs = []
      dirs = []
      for h in target_info[0]
        next unless h.battler
        next if h.controller == @owner
        targs.push(h.battler)
        dirs.push(@current_hex.get_direction_to(h))
      end
      damage_event = Damage_Ability.new(self, targs, abil_damage)
      time_out = Proc.new do |target, amount|
        Buff_Timed.new(self, target, Impact.new(:HASTE_MULTI, -0.5), 5)
        ch = target.current_hex
        ph = ch.hex_in_direction(dirs[targs.index(target)])
        next unless ph
        ph.set_battler(target)
      end
      damage_event.add_proc(time_out)
      damage_event.resolve()
    end

    hand = new_animation_sprite
    hand.bitmap = RPG::Cache.icon("Ability/Chronomancer/clock_hand.png")
    hand.ox = hand.center_x
    hand.oy = 96
    hand.x = @sprite.midpoint_x
    hand.y = @sprite.midpoint_y
    hand.z = @sprite.z + 40
    hand.add_rotation(-10, 36)
    hand.add_proc(strike)
    hand.add_wiggles(3, 3, 0.2*fps)
    hand.add_uproot(self)
    hand.add_dispose
  end
end

register_planeswalker(Daril)