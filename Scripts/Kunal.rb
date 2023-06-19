class Kunal < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Kunal",
      :cost       => 1,
      :synergy    => [:DRACONIC, :WARRIOR],
      :range      => 1,
      :power      => [65, 100, 150],
      :multi      => 10,
      :haste      => 0.65,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 40,
      :ward       => 10,
      :life       => [600, 1170, 2100],
      :ability_cost => 60,
      :starting_mana => 60.0,
      :mana_cooldown => 1.0,
      :slow_start => 0,
      :pronoun    => "he/him"
    }
  end

#Kunal: offtank with good damage. solid damage dealer for warrior comp, or tank for dragons. watch mana and blue-buffs
#Spell:Dragon Dance: Kunal dashes through his enemies past the lowest health enemy within two hexes, dealing
#MS-[200%/250%/300%] power damage to all enemies dashed through.

  def self.ability_aim
    return [:custom_ward, 2]
  end
  
  def self.ability_area
    return [:custom, 1]
  end
  
end

module AbilityLibrary
  def ability_script_kunal(target_info, mana_cost=@ability_cost)
    final_hex = target_info[2]
    # make sure our dash point still works
    return if final_hex.battler && final_hex != @current_hex
    start_hex = @current_hex
    target_hex = target_info[0][0]
    path = @current_hex.get_burrow_to(target_hex)
    abil_damage = 100 * mana_amp * get_value(:POWER)/65
    delay = 0
    step = 0.15
    delay += step
    
    # make a copy to manip instead of actual kunal
    clone_spr = new_animation_sprite
    clone_spr.bitmap = @sprite.bitmap
    clone_spr.x = @sprite.x
    clone_spr.y = @sprite.y
    clone_spr.z = @sprite.z + 30
    # make Kunal invisible and move him to the final hex
    @sprite.opacity = 0
    final_hex.set_battler(self)

    #charge Kunal across the path
    for id in path
      h = @owner.match.board.board_map[id]
      clone_spr.add_move_to(h.pixel_x, h.pixel_y, step*fps)
      fire_spr = new_animation_sprite
      fire_spr.bitmap = RPG::Cache.icon("Ability/flame.png")
      fire_spr.x = h.pixel_x
      fire_spr.y = h.pixel_y
      fire_spr.z = @sprite.z + 29
      fire_spr.opacity = 0
      fire_spr.add_wait(delay*fps)
      fire_spr.add_fade_to(255, step*fps)
      fire_spr.add_damage(Damage_Ability.new(self, nil, abil_damage), "enemy")
      fire_spr.add_fading(180, 255, 4, 0.3*fps)
      fire_spr.add_dispose
      delay += step
    end

    clone_spr.add_move_to(final_hex.pixel_x, final_hex.pixel_y, step*fps)
    clone_spr.add_dispose
    sc = @sprite.add_schedule
    @sprite.add_wait(delay*fps, sc)
    @sprite.add_fade_to(255, 1, sc)
    # cloak and root Kunal for the duration
    imps = [
      Impact.new(:CLOAK, 1),
      Impact.new(:Casting, 1)
    ]
    Buff_Timed.new(self, self, imps, delay)
  end
  
  def aim_script_kunal(range)
    return nil if @dead
    return nil unless @current_hex
    
    aggro = nil
    
    # check if we're taunted
    taunting = check_taunted()
    taunters = taunting[0]
    
    # check if we're confused
    confused = false #get_value(:CONFUSED) > 0
    if confused && taunters.length
      ts = []
      for t in taunters
        next unless t.owner == @owner
        ts.push(t)
      end
      taunters = ts
    end
    
    # hexes we can reach and hexes we can "see"
    areas = @current_hex.get_area_hexes(range)
    a_dists = {}
    for di in areas[1]
      for h in di[:hexes]
        a_dists[h.id] = di[:dist]
      end
    end

    # find new aggro target
    # if we're taunted and a taunter is dashable, send one at random
    unless taunters.empty?
      # taunting that we can hit
      taunts_in_range = taunting[1] & areas[0]
      unless taunts_in_range.empty?
        # pick at random
        taunts_in_range.shuffle
        for t in taunts_in_range
          ns = t.get_neighbors
          # that have a free hex next to them
          for n in ns
            next if n.battler
            return [t, n, areas]
          end
        end
      end
    end
    
    # not taunted or all out of range
    # see if anything's in range
    targs = []
    for h in areas[0]
      next unless h.battler
      next unless (h.battler.owner == @owner) == confused
      next unless can_target?(h)
      targs.push(h)
    end
    d = [nil, @current_hex, 0, 9999999]
    for t in targs
      ns = t.get_neighbors
      l = t.battler.get_life
      next if l > d[3]
      for n in ns
        next if n.battler
        dist =  a_dists[n.id]
        d = [t, n, dist, l]
        break
      end
    end
    if d[0] == nil
      # if no one in range, dash towards aggro
      aggro = @aggro
      unless aggro
        d = 99999
        for u in @owner.opponent.deployed
          next unless can_target?(u.current_hex)
          dist = @current_hex.get_px_dist_to(u.current_hex)
          if dist < d
            d = dist
            aggro = u
          end
        end
      end
      return nil unless aggro
      h1 = @current_hex.step_towards(aggro.current_hex, true)
      d[0] = h1.step_towards(aggro.current_hex, true)
      ns = d[0].get_neighbors
      for n in ns
        next if n.battler
        d[1] = n
        break
      end
    end
    return [d[0], d[1]]
  end
  
  def aim_script_kunal2(range)
    aggro = nil
    
    # check if we're taunted
    taunting = check_taunted()
    taunters = taunting[0]
    
    # check if we're confused
    confused = false #get_value(:CONFUSED) > 0
    if confused && taunters.length
      ts = []
      for t in taunters
        next unless t.owner == @owner
        ts.push(t)
      end
      taunters = ts
    end
    
    # hexes we can reach and hexes we can "see"
    areas = @current_hex.get_area_hexes(2)

    # find new aggro target
    # if we're taunted and a taunter is dashable, send one at random
    unless taunters.empty?
      # taunting that we can hit
      taunts_in_range = taunting[1] & areas[0]
      unless taunts_in_range.empty?
        # pick at random
        taunts_in_range.shuffle
        for t in taunts_in_range
          ns = t.get_neighbors
          # that have a free hex next to them
          for n in ns
            next if n.battler
            return [t, n, areas]
          end
        end
      end
    end
    
    # not taunted or all out of range
    # grab the lowest hp enemy in two hexes
    d = [1000000, nil]
    for h in areas[0]
        next unless h.battler
        l = h.battler.get_life
        d = [l, h] if l < d[0]
    end
    return nil unless d[1]
    landing = nil
    path = @current_hex.get_burrow_to(d[1])
    for h in d[1].get_neighbors
      next if h.battler
      next if path.include?(h.id)
      landing = h
    end
    return nil unless landing
    return [d[1], landing, path]
  end
  
  def area_script_kunal(targetHex, range)
    return [[targetHex[0]], [{:dist => 0, :hexes => [targetHex[0]]}], targetHex[1]]
  end
end

register_planeswalker(Kunal)
