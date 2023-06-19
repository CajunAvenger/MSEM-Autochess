# The base AI of this unit
class Unit
  
  # get aggro of unit within range
  def get_aggro(range, move, old=false)
    return nil if @dead
    return nil unless @current_hex
    
    aggro = nil
    
    # check if we're taunted
    taunting = check_taunted()
    taunters = taunting[0]
    
    # check if we're confused
    confused = get_value(:CONFUSED) > 0
    if confused && taunters.length
      ts = []
      for t in taunters
        next unless t.owner == @owner
        ts.push(t)
      end
      taunters = ts
    end
    
    # hexes we can reach and hexes we can "see"
    areas = @current_hex.get_attack_hexes(range, move)
    # use attack @aggro
    if old && @aggro
      aggro = @aggro
      # reset if the old aggro has escaped
      aggro = nil unless (areas[0]+areas[1]).include?(@aggro.current_hex)
      # reset if we're taunted by someone else
      aggro = nil if taunters.length > 0 && !taunters.include?(@aggro)
      # reset if the old aggro is dead
      aggro = nil if @aggro && @aggro.dead
      # reset if our aggro is cloaked
      aggro = nil if @aggro && @aggro.get_value(:CLOAK) > 0
      # reset our aggro depending on our confused status
      aggro = nil if @aggro && (@aggro.owner == @owner) != confused
      # if we still have aggro, send that and if it's in attack range
      return [aggro, areas[0].include?(@aggro.current_hex), areas] if aggro
    end
    
    # otherwise find new aggro target
    # if we're taunted and a taunter is pathable, send the nearest
    unless taunters.empty?
      # taunting that we can hit
      taunts_in_range = taunting[1] & areas[0]
      unless taunts_in_range.empty?
        r = rand(taunts_in_range.length)
        aggro = taunts_in_range[r].battler
        return [aggro, true, areas, true]
      end
      # taunting that we're not sure if we can hit
      areas = @current_hex.get_path_distance_to(taunting[1])
      unless areas[2].empty?
        d = 100
        h = nil
        for hex, dist in areas[2]
          if dist < d
            d = dist
            h = hex
          end
        end
        aggro = @owner.match.board.board_map[h].battler
        return [aggro, false, areas]
      end
    end
    
    # either aggro's been reset or we're taunted by stuff we can't reach
    # see if anything's in range
    for h in areas[0]
      next unless h.battler
      next unless (h.battler.owner == @owner) == confused
      next unless can_target?(h)
      aggro = h.battler
      return [aggro, true, areas]
    end
    # see if anything's in sight
    for h in areas[1]
      next unless h.battler
      next unless (h.battler.owner == @owner) == confused
      next unless can_target?(h)
      aggro = h.battler
      return [aggro, false, areas]
    end

    # no aggro, let main script determine how to handle
    return [nil, false, areas]
  end
  
  # get target with free hex to dash to, [target, free_hex, areas]
  def get_dash_target(range)
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
    d = [nil, nil, 0]
    for t in targs
      ns = t.get_neighbors
      for n in ns
        next if n.battler
        dist =  a_dists[n.id]
        return [t, n, areas] if !dist
        d = [t, n, dist] if dist > d[2]
      end
    end
    return [d[0], d[1], areas]
    # no aggro, let main script determine how to handle
    return [nil, @current_hex, areas]
  end

  def try_attack(refundable=true)
    return if @dead
    return if @impacts.include?(:Casting)
    range = get_value(:RANGE)
    mv = movement
    if mv > 0 && get_value(:Wander) > 0
      for n in @current_hex.get_neighbors
        next if n.battler
        break if n.set_battler(self)
      end
      return
    end
    ag_info = get_aggro(range, mv, true)
    @aggro = ag_info[0]
    taunted = ag_info[3]
    # if no one's close enough, grab whoever's closest to start moving to
    unless @aggro
      d = 99999
      for u in @owner.opponent.deployed
        next unless can_target?(u.current_hex)
        dist = @current_hex.get_px_dist_to(u.current_hex)
        if dist < d
          d = dist
          @aggro = u
        end
      end
    end

    @transit = true
    if @aggro && ag_info[1]
      @transit = false
      # we can attack
      # get info together for emitters to edit as needed
      # :times -> number of times to attack, discounting base multistrike roll
      # :aggro -> unit being attacked
      # :multi -> cached multiattack chance
      # :multi_roll -> roll for base multistrike
      attack_keys = {
        :times => 1,
        :attacker => self,
        :aggro => @aggro,
        :range => range,
        :multi => get_value(:MULTI),
        :multi_roll => rand(100),
        :extra_p => 0,
        :extra_td => 0,
        :procs => []
      }
      # give emitters chance to change the keys
      emit(:Attacking, attack_keys)
      # check for base multistrike
      attack_keys[:times] += 1 if attack_keys[:multi_roll] < attack_keys[:multi]
      # give defending emitters chance to change the keys
      attack_keys[:aggro].emit(:BeingAttacked, attack_keys)
      for i in 1..attack_keys[:times]
        apply_mana_heal(ManaHeal.new(10)) unless @mana_cooldown > 0
        pow = get_value(:POWER) + attack_keys[:extra_p]
        td = get_value(:TRUE_DAMAGE) + attack_keys[:extra_td]
        damage_event = Damage_Attack.new(self, @aggro, pow, td)
        damage_event.add_procs(attack_keys[:procs]) if attack_keys[:procs].length > 0
        cond_keys(attack_keys, damage_event, i)
        damage_event.execute = attack_keys[:execute] if attack_keys[:execute]
        # draw the sprite
        attack_animation(attack_keys, damage_event, i)
        emit(:Attacked, attack_keys, i)
        emit(:Multistriked, attack_keys, i) if i > 1
      end
      emit(:DoneAttacking, attack_keys)
      # Cat interactions
      emit(:CatTax, attack_keys)
      @transit = true if !aggro || @aggro.dead
    elsif @aggro && mv > 0
      # we have aggro but need to move
      if !@path_cache || !@path_cache.include?(@aggro.current_hex)
        @path_cache = @current_hex.get_path_to_new(@aggro.current_hex, !taunted)
      end
      unless @path_cache
        # can't path, just try to walk at @aggro
        friend = @current_hex.path_towards(@aggro.current_hex)
        return unless friend
        @path_cache = [@current_hex.id, friend.id]
      end
      # max movement
      mv = mv.cap(@path_cache.length-2)
      # try to move to a hex
      for j in 1..mv
        i = mv - (j-1)
        hex = @owner.match.board.board_map[@path_cache[i]]
        next unless hex
        moved = hex.set_battler(self)
        break if moved
      end

      # update the path cache
      until @path_cache[0] == @current_hex.id || @path_cache.length == 0
        @path_cache.delete_at(0)
      end
      # refund part of our ticker to attack after we move
      if refundable
        if @synergies.include?(:CAT) && @owner.synergy_handlers[:CAT].level > 0
          @ticker += 0.3*tps/get_value(:HASTE)
        else
          @ticker += 0.1*tps/get_value(:HASTE)
        end
      end
    end
  end
  
  def cond_keys(attack_keys, damage_event, i)
    if attack_keys.include?(:six_shot) && attack_keys.include?(:chain_six)
      chain = Proc.new do |target, amount|
        chain_to = target.current_hex.get_closest_ally
        next unless chain_to && chain_to.battler
        pow = self.get_value(:POWER) + attack_keys[:extra_p]
        td = self.get_value(:TRUE_DAMAGE) + attack_keys[:extra_td]
        damage_event2 = Damage_Attack.new(self, chain_to.battler, pow, td)
        damage_event2.add_procs(attack_keys[:procs]) if attack_keys[:procs].length > 0
        damage_event2.execute = attack_keys[:execute] if attack_keys[:execute]
        # draw the sprite
        self.attack_animation(attack_keys, damage_event2, i, target.current_hex, chain_to.battler)
      end
      damage_event.add_proc(chain)
    end
  end
  
  def attack_animation(attack_keys, damage_event, i, from_hex=@current_hex, targ=nil)
    # the sprite we're attacking
    target = attack_keys[:aggro]
    target = targ if targ
    tsprite = target.sprite
    # the main attack sprite
    sprite = new_animation_sprite
    # direction to the target
    sprite.bitmap = build_attack_sprite(attack_keys)
    # sprite begins on unit
    sprite.x = from_hex.center_x
    sprite.y = from_hex.center_y
    sprite.z = 6030
    sprite.ox = sprite.center_x
    sprite.oy = sprite.center_y
    if attack_keys.include?(:siraj)
      sprite.bitmap = RPG::Cache.icon("Ability/rhand.png")
      sprite.angle = 0
    end
    # delay multistrikes
    sprite.add_wait(0.1*(i-1)*fps)
    # move towards target
    sprite.add_slide_to(tsprite, 0.3*fps)
    case attack_anim_type
    when :spider
      sprite.add_scan(20, 0.1*fps, 0, sprite.add_schedule)
    else
      sprite.angle = angle_of(from_hex, tsprite)
    end
    # if salva ability, delay damage slightly to line up with the animation
    unless attack_keys.include?(:salva)
      sprite.add_damage(damage_event)
    else
      # Salva augmented attack animation
      th1 = sprite.angle
      th2 = nil
      th3 = 90
      if th1 == 0
        # right
        th2 = 45
        th3 = 315
      elsif th1 < 90
        # top right
        th2 = th1 + 90
      elsif th1 == 90
        # top
        th2 = 45
        th3 = 135
      elsif th1 < 180
        # top left
        th2 = 180 - th1
      elsif th1 == 180
        # left
        th2 = 135
        th3 = 225
      elsif th1 < 270
        # bottom left
        th2 = 360 - (th1-180)
        th3 = 270
      elsif th1 == 270
        # bottom
        th2 = 225
        th3 = 315
      elsif th1 < 360
        # bottom right
        th2 = 540 - th1
        th3 = 270
      end
      
      t1x = 20
      t1x = -20 if th1.between?(90, 270)
      t1x = 0 if th1 == 90 || th1 == 270
      t1y = 20
      t1y = -20 if th1 < 180

      t2x = 20
      t2x = -20 if th2.between?(90, 270)
      t2x = 0 if th2 == 90 || th2 == 270
      t2y = 20
      t2y = -20 if th2 < 180
      
      t3x = 20
      t3x = -20 if th3.between?(90, 270)
      t3x = 0 if th3 == 90 || th3 == 270
      t3y = 20
      t3y = -20 if th3 < 180
      
      sprite.add_wait((0.1*(i-1)+0.3)*fps, 1)
      sprite.add_damage(damage_event, "standard", 1)
      sprite.add_translate(t1x/2, t1y/2, 0.2*fps)
      sprite.add_wait(0.2*fps)

      sprite2 = new_animation_sprite
      sprite2.bitmap = build_attack_sprite(attack_keys)
      sprite2.ox = sprite.center_x
      sprite2.oy = sprite.center_y
      sprite2.x = target.current_hex.midpoint_x - (t2x/2)
      sprite2.y = target.current_hex.midpoint_y - (t2y/2)
      sprite2.z = sprite.z
      sprite2.angle = th2
      sprite2.add_wait(0.1*(i-1)*fps)
      sprite2.add_translate(t2x, t2y, 0.3*fps)
      sprite2.add_wait(0.4*fps)
      sprite2.add_dispose
      
      sprite3 = new_animation_sprite
      sprite3.bitmap = build_attack_sprite(attack_keys)
      sprite3.ox = sprite.center_x
      sprite3.oy = sprite.center_y
      sprite3.x = target.current_hex.midpoint_x - (t3x/2)
      sprite3.y = target.current_hex.midpoint_y - (t3y/2)
      sprite3.z = sprite.z
      sprite3.angle = th3
      sprite3.add_wait(0.1*(i-1)*fps)
      sprite3.add_translate(t3x, t3y, 0.3*fps)
      sprite3.add_wait(0.4*fps)
      sprite3.add_dispose
    end
    # Haide augmented attack animation
    if attack_keys.include?(:haide)
      blam_sprite = new_animation_sprite
      blam_sprite.bitmap = RPG::Cache.icon("Ability/Gunslinger/blam.png")
      blam_sprite.center_on(tsprite)
      blam_sprite.z = tsprite.z + 30
      blam_sprite.opacity = 0
      blam_sprite.add_wait((0.1*(i-1)+0.3)*fps)
      blam_sprite.add_fade_to(255, 1)
      blam_sprite.add_fade_to(0, 0.4*fps)
      blam_sprite.add_dispose
    end
    # finally, dispose the attack sprite
    sprite.add_dispose
  end
  
  def attack_animation_old(attack_keys, damage_event, i)
    sprite = new_animation_sprite
    dir = @current_hex.get_direction_to(attack_keys[:aggro].current_hex)
    sprite.bitmap = build_attack_sprite(dir)
    sprite.x = @current_hex.pixel_x
    sprite.y = @current_hex.pixel_y
    sprite.z = @sprite.z + 30
    sprite.add_wait(0.1*(i-1)*fps)
    sprite.add_slide_to(attack_keys[:aggro].sprite, 0.3*fps)
    sprite.add_damage(damage_event)
    sprite.add_dispose
=begin
      dir = @current_hex.get_direction_to(attack_keys[:aggro].current_hex)
      pair_dirs = {
        :top_right => [:top_left, :top],
        :right => [:top_left, :top],
        :top_left => [:top_right, :top],
        :left => [:top_right, :top],
        :top => [:top_right, :top_left],
        :bottom_right => [:bottom_left, :bottom],
        :bottom_left => [:bottom_right, :bottom],
        :bottom => [:bottom_right, :bottom_left]
      }
      travels = {
        :top_right => [20, -20],
        :right => [20, -20],
        :top_left => [-20, -20],
        :left => [-20, -20],
        :top => [0, -20],
        :bottom_right => [20, 20],
        :bottom_left => [-20, 20],
        :bottom => [0, 20],
      }
      dir2 = pair_dirs[dir][0]
      dir3 = pair_dirs[dir][1]
      travel1 = travels[dir]
      travel2 = travels[dir2]
      travel3 = travels[dir3]
      

      sprite2 = new_animation_sprite
      sprite2.bitmap = build_attack_sprite(attack_keys)
      sprite2.x = target.current_hex.pixel_x - (travel2[0]/2)
      sprite2.y = target.current_hex.pixel_y - (travel2[1]/2)
      sprite2.z = tsprite.z + 30
      sprite2.add_wait(0.1*(i-1)*fps)
      sprite2.add_translate(travel2[0], travel2[1], 0.2*fps)
      sprite2.add_wait(0.5*fps)
      sprite2.add_dispose
      
      sprite3 = new_animation_sprite
      sprite3.bitmap = build_attack_sprite(attack_keys)
      sprite3.x = target.current_hex.pixel_x - (travel3[0]/2)
      sprite3.y = target.current_hex.pixel_y - (travel3[1]/2)
      sprite3.z = tsprite.z + 30
      sprite3.add_wait(0.1*(i-1)*fps)
      sprite3.add_translate(travel3[0], travel3[1], 0.3*fps)
      sprite3.add_wait(0.4*fps)
      sprite3.add_dispose

      th1 = sprite.angle
      th2 = nil
      th3 = nil
      md = th1 % 90
      if md == 0
        th2 = th1 - 45
        th3 = th1 + 45
      else
        tb = 90 * (th1.to_f / 90).ceil
        nb = tb + 90
        th2 = nb - th1
        th3 = tb
      end
      
      #console.log(th1)
      #console.log(th2)
      #console.log(th3)
      
=end
  end
  
  def try_ability(key=@name, cost=@ability_cost, iter=[])
    return if @dead
    prim = primary_target(key)
    return unless prim
    @cached_cost = 0+cost
    target_info = collect_targets(prim, key)
    return unless target_info
    
    #console.log("checking immune")
    rem = []
    for t in target_info[0]
      rem.push(t) unless can_target?(t)
    end
    target_info[0] = target_info[0] - rem
    if target_info[1]
      for d in target_info[1]
        d[:hexes] = d[:hexes] - rem
      end
    end
    #console.log("checking ward")
    aim = ability_aim(key)[0]
    unwarded = [:on_me, :ally, :custom_unward]
    unless unwarded.include?(aim)
      wb = 0
      for hex in target_info[0]
        next unless hex.battler
        next unless hex.battler.owner != @owner
        w = hex.battler.get_value(:WARD)
        wb = w if w > wb
      end
      ward_pen = 1 - get_value(:WARD_UNMULTI)
      ward_cost = wb * ward_pen
      @cached_cost += ward_cost if ward_cost > 0
    end
    #console.log("emitting target")
    if @mana < @cached_cost
      emit(:Warded, @cached_cost - @mana)
      console.log("emitted")
      return
    end
    starting = target_info[0].length
    # loop backwards so targets removing themselves don't screw the loop
    for i in 1..starting
      hex = target_info[0][starting-i]
      break if starting-1 < 0
      next unless hex.battler
      hex.battler.emit(:BeingTargeted, self, target_info)
      if hex.battler && hex.battler.owner == @owner
        hex.battler.emit(:BeingTargetedAlly, self, target_info)
      elsif hex.battler
        hex.battler.emit(:BeingTargetedEnemy, self, target_info)
      end
    end
    emit(:Casting, target_info, @cached_cost, key)
    ability_script(target_info, @cached_cost, key)
    if cost == 0
      @mana -= @cached_cost
    else
      @mana = 0
    end
    mc = get_base_stats[:mana_cooldown]
    mc = 1 unless mc
    @mana_cooldown = tps * mc
    @cached_cost = nil
    emit(:UsedAbility, target_info, iter)
    @temp_amp = 0
    update_mana
  end
  
  # get the primary target of the ability
  # based on the key in ability_aim()
  def primary_target(key)
    targetHex = nil
    cost = @ability_cost
    ainfo = ability_aim(key)
    case ainfo[0]
    when :on_me
      targetHex = @current_hex
    when :around_me
      targetHex = @current_hex
    when :aggro
      ag_info = get_aggro(ainfo[1], 0)
      areas = ag_info[2]
      if ag_info[0]
        targetHex = ag_info[0].current_hex
      end
    when :dash
      targetHex = get_dash_target(ainfo[1])
    when :ally
      targetHex = find_ally(ainfo[1], ally_type(key))
    when :closest_enemy
      targetHex = @current_hex.get_closest_enemy
    when :custom_ward
      targetHex = custom_aim(key, ainfo[1])
    when :custom_unward
      targetHex = custom_aim(key, ainfo[1])
    end
    return targetHex
  end
  
  # get all the hexes targeted by an ability
  # based on the key and range in ability_area()
  def collect_targets(targetHex, key)
    ainfo = ability_area(key)
    range = ainfo[1]
    out = nil
    case ainfo[0]
    when :aggro
      out = [[targetHex], [{:dist => 0, :hexes => [targetHex]}]]
    when :dash
      out = [[targetHex[0]], [{:dist => 0, :hexes => [targetHex[0]]}], targetHex[1]]
    when :area
      out = targetHex.get_area_hexes(range)
    when :line
      dir = @current_hex.get_direction_to(targetHex)
      out = @current_hex.get_line(dir, range)
    when :cone
      dirs = @current_hex.get_cones_to(targetHex)
      ts = -1
      back = nil
      for d in dirs
       test = @current_hex.get_cone(d, range)
       back = test
       if test[2] > ts
         out = test
         out.push(d)
         ts = test[2]
       end
       out = back if out == nil
     end
    when :burst
      dir = @current_hex.get_direction_to(targetHex)
      out = @current_hex.get_burst(dir, range)
    when :all
      max = (@owner.match.board.x + 0.5*@owner.match.board.y).ceil
      out = @current_hex.get_area_hexes(max)
    when :none
      out = [[], {}]
    when :empty
      out = @current_hex.get_area_hexes(range, true)
    when :custom
      out = custom_area(key, targetHex, range)
    end
    return out
  end
  
  def breaks_cloak
    return false
  end
   
end