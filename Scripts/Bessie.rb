class Bessie < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Bessie",
      :cost       => 4,
      :synergy    => [:WURM, :THESPIAN],
      :range      => [1, 1, 1],
      :power      => [40, 20, 40],
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
    return [:dash, 5]
  end
  
  
  def self.ability_area
    return [:dash, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/gmouth.png"
  end
  
end

module AbilityLibrary
  
  def burrow_path(d1, d2)
    vs = [:top_left, :top_right, :right, :bottom_right, :bottom_left, :left]
    i1 = vs.index(d1)
    i2 = vs.index(d2)
    ar = [
      [["36", 0], ["36", 0], ["13", 0], ["14", 0], ["15", 0], ["36", 0]],
      [["36", 0], ["36", 0], ["36", 0], ["24", 0], ["25", 0], ["26", 0]],
      [["13", 180], ["36", 0], ["36", 0], ["36", 0], ["26", 180], ["36", 0]],
      [["14", 0], ["24", 0], ["36", 0], ["36", 0], ["36", 0], ["13", 180]],
      [["15", 0], ["25", 0], ["26", 180], ["36", 0], ["36", 0], ["36", 0]],
      [["36", 0], ["26", 0], ["36", 180], ["13", 180], ["36", 0], ["36", 0]]
    ]
    return ar[i1][i2]
  end
  
  def ability_script_bessie(target_info, mana_cost=@ability_cost)
    final_hex = target_info[2]
    # make sure our burrow point still works
    return if final_hex.battler
    start_hex = @current_hex
    abil_damage = 100 * mana_amp
    stun_time = 2
    delay = 0.3*fps
    path = @current_hex.get_burrow_to(final_hex)

    # cover Bessie with a brown hex
    dig_spr = new_animation_sprite
    dig_spr.bitmap = RPG::Cache.icon("Ability/Hexes/brown.png")
    dig_spr.x = @current_hex.x
    dig_spr.y = @current_hex.y
    dig_spr.z = @sprite.z+11
    dig_spr.opacity = 0
    dig_spr.add_fade_to(200, delay)
    dig_spr.add_wait(0.3*fps)
    dig_spr.add_dispose()
    # make Bessie invisible and move her to the final hex
    @sprite.opacity = 0

    # make a copy to manip instead of actual bessie
    clone_spr = new_animation_sprite
    clone_spr.bitmap = @sprite.bitmap
    clone_spr.x = @sprite.x
    clone_spr.y = @sprite.y
    clone_spr.z = @sprite.z
    sch0 = clone_spr.add_schedule()
    clone_spr.add_fade_to(0, delay-2, sch0)
    clone_spr.add_snap(final_hex.pixel_x, final_hex.pixel_y, sch0)
    final_hex.set_battler(self)

    # draw burrow line and stun
    for i in 0..path.length-1
      h = @owner.match.board.board_map[path[i]]
      next if h == start_hex
      next if h == final_hex
      hp = @owner.match.board.board_map[path[i-1]]
      hn = @owner.match.board.board_map[path[i+1]]
      delay += 0.15*fps
      burrow_spr = new_animation_sprite
      d1 = h.get_direction_to(hp)
      d2 = h.get_direction_to(hn)
      bi = burrow_path(d1, d2)
      burrow_spr.bitmap = RPG::Cache.icon("Ability/Bessie/burrow_"+bi[0]+".png")
      burrow_spr.center_on(h)
      burrow_spr.angle = bi[1]
      burrow_spr.z = @sprite.z+11
      burrow_spr.opacity = 0
      burrow_spr.add_wait(delay)
      burrow_spr.add_fade_to(200, 1)
      burrow_spr.add_fade_to(0, 2.5*fps-delay)
      burrow_spr.add_dispose()
      stun_you = Proc.new do |frames, hex|
        next unless hex.battler
        next if hex.battler.owner == @owner
        Buff_Timed.new(self, hex.battler, Impact.new(:STUN, 1), stun_time)
      end
      $timer.add_framer(delay, stun_you, h)
    end

    sch1 = clone_spr.add_schedule()
    sch2 = clone_spr.add_schedule()
    clone_spr.add_wait(delay, sch1)
    clone_spr.add_wait(delay, sch2)
    # reveal and vibrate Bessie
    clone_spr.add_fade_to(255, 0.3*fps, sch1)
    clone_spr.add_wiggles(5, 5, 0.5*fps, sch2)
    # then dispose and reshow the real one
    clone_spr.add_dispose(sch2)
    sch3 = @sprite.add_schedule
    @sprite.add_wait(delay + 0.5*fps + 1, sch3)
    @sprite.add_fade_to(255, 1, sch3)
    delay += 0.4*fps

    # ring of explosion sprites w/damage
    for h in final_hex.get_neighbors
      rock_spr = new_animation_sprite
      rock_spr.bitmap = RPG::Cache.icon("Weapon/brrock.png")
      rock_spr.angle = angle_of(@sprite, h)
      rock_spr.visible = false
      rock_spr.center_on(final_hex)
      rock_spr.z = @sprite.z + 12
      rock_spr.add_wait(delay)
      rock_spr.switch_visible()
      rock_spr.add_move_to(h.midpoint_x, h.midpoint_y, 0.4*fps)
      rock_spr.add_damage(Damage_Ability.new(self, [], abil_damage), "enemy")
      rock_spr.add_dispose()
    end
    # cloak and root Bessie for the duration
    imps = [
      Impact.new(:CLOAK, 1),
      Impact.new(:Casting, 1)
    ]
    Buff_Timed.new(self, self, imps, delay/fps)
  end
  
  def ability_script_bessie2(target_info, mana_cost=@ability_cost)
    final_hex = target_info[0][0]
    # make sure our burrow point still works
    return if final_hex.battler
    start_hex = @current_hex
    dir = @current_hex.get_direction_to(final_hex)
    line = @current_hex.get_line(dir, 4)[0]
    abil_damage = 100 * mana_amp
    stun_time = 2
    delay = 0.3*fps

    # cover Bessie with a brown hex
    dig_spr = new_animation_sprite
    dig_spr.bitmap = RPG::Cache.icon("Ability/Hexes/brown.png")
    dig_spr.x = @current_hex.x
    dig_spr.y = @current_hex.y
    dig_spr.z = @sprite.z+11
    dig_spr.opacity = 0
    dig_spr.add_fade_to(200, delay)
    dig_spr.add_wait(0.3*fps)
    dig_spr.add_dispose()
    # make Bessie invisible and move her to the final hex
    @sprite.opacity = 0

    # make a copy to manip instead of actual bessie
    clone_spr = new_animation_sprite
    clone_spr.bitmap = @sprite.bitmap
    clone_spr.x = @sprite.x
    clone_spr.y = @sprite.y
    clone_spr.z = @sprite.z
    sch0 = clone_spr.add_schedule()
    clone_spr.add_fade_to(0, delay-2, sch0)
    clone_spr.add_snap(final_hex.pixel_x, final_hex.pixel_y, sch0)
    final_hex.set_battler(self)
    # draw burrow line and stun

    b_angle = angle_of(start_hex, final_hex)
    for h in line
      next if h == start_hex
      break if h == final_hex
      delay += 0.15*fps
      burrow_spr = new_animation_sprite
      burrow_spr.bitmap = RPG::Cache.icon("Ability/burrow.png")
      burrow_spr.center_on(h)
      burrow_spr.angle = b_angle
      burrow_spr.z = @sprite.z+11
      burrow_spr.opacity = 0
      burrow_spr.add_wait(delay)
      burrow_spr.add_fade_to(200, 1)
      burrow_spr.add_fade_to(0, 2.5*fps-delay)
      burrow_spr.add_dispose()
      stun_you = Proc.new do |frames, hex|
        next unless hex.battler
        next if hex.battler.owner == @owner
        Buff_Timed.new(self, hex.battler, Impact.new(:STUN, 1), stun_time)
      end
      $timer.add_framer(delay, stun_you, h)
    end
    sch1 = clone_spr.add_schedule()
    sch2 = clone_spr.add_schedule()
    clone_spr.add_wait(delay, sch1)
    clone_spr.add_wait(delay, sch2)
    # reveal and vibrate Bessie
    clone_spr.add_fade_to(255, 0.3*fps, sch1)
    clone_spr.add_wiggles(5, 5, 0.5*fps, sch2)
    # then dispose and reshow the real one
    clone_spr.add_dispose(sch2)
    sch3 = @sprite.add_schedule
    @sprite.add_wait(delay + 0.5*fps + 1, sch3)
    @sprite.add_fade_to(255, 1, sch3)
    delay += 0.4*fps
    # ring of explosion sprites w/damage
    for h in target_info[0]
      next if h == final_hex
      rock_spr = new_animation_sprite
      rock_spr.bitmap = RPG::Cache.icon("Weapon/brrock.png")
      rock_spr.angle = angle_of(@sprite, h)
      rock_spr.visible = false
      rock_spr.center_on(final_hex)
      rock_spr.z = @sprite.z + 12
      rock_spr.add_wait(delay)
      rock_spr.switch_visible()
      rock_spr.add_move_to(h.midpoint_x, h.midpoint_y, 0.4*fps)
      rock_spr.add_damage(Damage_Ability.new(self, [], abil_damage), "enemy")
      rock_spr.add_dispose()
    end
    # cloak and root Bessie for the duration
    imps = [
      Impact.new(:CLOAK, 1),
      Impact.new(:Casting, 1)
    ]
    Buff_Timed.new(self, self, imps, delay/fps)
  end
  
  def aim_script_bessie(range)
    dirs = [:top_right, :right, :bottom_right, :bottom_left, :left, :top_left]
    tag_hexes = []
    dists = []
    areas = []
    line_tags = []
    # get possible burrow points
    for d in dirs
      line = @current_hex.get_line(d, 4)[0]
      next if line == nil || line.empty?
      line = line.reverse
      i = line.length+1
      grabbed = false
      tags = 0
      for test_hex in line
        i -= 1
        tags += 1 if test_hex.battler && test_hex.battler.owner != @owner
        next if test_hex.battler
        next if grabbed
        tag_hexes.push(test_hex)
        dists.push(i)
        areas.push(test_hex.get_area_hexes(1, true))
        grabbed = true
      end
      line_tags.push(tags)
    end
    d = 0
    main = -1
    back = 0
    # pick the furthest one with targets
    for i in 0..tag_hexes.length-1
      if dists[i] > d
        back = i
        next unless areas[i][2] > 0
        d = dists[i]
        main = i
      end
    end
    # if no targets, try to charge aggro
    if main == -1
      if @aggro && @aggro.current_hex
        dir = @current_hex.get_direction_to(@aggro.current_hex)
        main = dirs.index(dir)
      else
        # if no aggro, charge the best stun line
        d = -1
        for di in line_tags
          if di > d
            d = di
            dir = @current_hex.get_direction_to()
            main = dirs[line_tags.index(di)]
          end
        end
      end
    end
    
    return tag_hexes[main]
  end

end

register_planeswalker(Bessie)