# A player
class Player_Battler < Emitter
  attr_reader :gm               # the gm
  attr_reader :id               # id number
  attr_accessor :name           # account name
  attr_accessor :gold           # total gold available
  attr_accessor :round_gold     # total gold available
  attr_accessor :life           # current life total
  attr_accessor :xp             # current experience
  attr_accessor :level          # current level
  attr_accessor :interest_cap   # normally 5, can be increased
  attr_accessor :unit_bonus     # can you have extra units?
  attr_accessor :force_deploy   # deploy if you're not using all slots
                                  # disabled by Auras that may want free spots
                                  
  attr_accessor :shop_counter   # number of times you've rolled the shop
  attr_accessor :blood_units    # ids of things paid for in life instead of gold
  attr_accessor :common_units   # ids of things more likely to show up in the store
  attr_accessor :streak         # current streak
  attr_accessor :wins_counter   # total wins
  attr_accessor :losses_counter # total losses
  attr_accessor :refresh_counter# number of refreshes this round
  attr_accessor :sell_artifacts # can this player sell artifacts?
  attr_accessor :empowered      # effects from auras
  attr_accessor :unique_builds  # unique artifacts this has built
  
  attr_accessor :board          # their main GameBoard
  attr_accessor :bench          # their bench GameBoard
  attr_accessor :refresh_aoes   # eternal AoEs to refresh on new match
  attr_accessor :deployed       # array of deployed units
  attr_accessor :storefront     # their Storefront
  attr_accessor :units          # all current units
  attr_reader :spare            # saved freebie units waiting for the bench
  attr_reader :auras            # all current auras
  attr_reader :artifacts        # all current artifacts
  attr_accessor :buffs          # buffs on this player
  attr_accessor :impacts        # impacts affecting this player
  attr_reader :synergy_handlers # each of the Synergy instances for this
  attr_reader :syn_tray         # each of the Synergy instances for this

  attr_accessor :opponent       # current opponent
  attr_accessor :match          # their active GameBoard
 
  def initialize(id, gm)
    @listening_to_me = {}
    @my_listener_cache = []
    @gold = 0
    @round_gold = 0
    @xp = 0
    @level = 1
    @level = 3
    @life = 100
    @unit_bonus = 0
    @interest_cap = 5
    @blood_units = []
    @common_units = []
    @shop_counter = 0
    @deaths_counter = 0
    @kills_counter = 0
    @refresh_counter = 0
    @streak = 0
    @game = nil
    @bench = []
    @deployed = []
    @refresh_aoes = []
    @units = {}
    @spare = []
    @auras = []
    @buffs = {}
    @artifacts = []
    @impacts = {}
    @synergy_handlers = {}
    @unique_builds = []
    @empowered = []
    @sell_artifacts = false
    @id = id
    @gm = gm
    @board = GameBoard.new(self)
    @bench = GameBoard.new(self, true)
    for short, long in $synergies do
      syn_han = long.new(self)
      @synergy_handlers[short] = syn_han
    end
    @syn_tray = nil
    @syn_tray = SynergyTray.new(self) if @id == 1
    @name = "Cajun"
  end
  
  # object controllers
  def give_unit(unit, placer=nil)
    unit.owner = self
    place_hex = nil
    # if given a specific hex, place it there
    if placer.is_a?(Hex) and !placer.battler
      place_hex = placer
    end
    # otherwise place it on the bench or near the placer, depending
    # unit should be either a walker, a token, or a temp clone
    # units try to go to the bench, and goes to @spare otherwise
    # tokens and clones go nearby their placer
    # or a random free hex if they're all filled
    unless place_hex
      # planeswalker from lobby, store, auras, etc
      if unit.is_a?(Planeswalker) && placer == nil
        # try to put it on the bench
        bench_hex = @bench.board_map[:Hex00]
        while place_hex == nil
          if bench_hex.battler
            bench_hex = bench_hex.right_hex
          else
            place_hex = bench_hex
          end
          break if bench_hex == nil
        end
        # if we didn't have bench space, save it to our spares
        # we'll throw it on the bench the next time the bench is empty
        if place_hex == nil
          @spare.push(unit)
        end
      # token or temp with placer
      elsif placer
        
        if placer.is_a?(Unit)
          # try free hexes around our source
          area = placer.current_hex.get_area_hexes(2)
          near_hexes = area[1][1][:hexes] + area[1][2][:hexes]
          for hex in near_hexes
            next if hex.battler
            place_hex = hex
            break
          end
        end
        
        unless place_hex
          for h, hex in @board.board_map
            next if hex.battler
            next unless hex.start_player == self
            place_hex = hex
          end
        end
      end
    end
    # if we didn't find a hex, reject it
    return false if place_hex == nil
    @units[unit.id] = unit
    sprite = $scene.spriteset.add_hex_to_port(Sprite_Chess)
    unit.place_sprite(sprite)
    unit.sprite.add_fade_to(0, 1)
    place_hex.set_battler(unit)
    if @match && !unit.is_benched?
      @deployed.push(unit)
      unit.deployed = true
    end
    unit.sprite.add_fade_to(255, 0.1*fps)
    unit.ticker -= 0.5*$ticks_per_second
    for id, s in @synergy_handlers
      s.apply(unit) if s.blanketer
    end
    synergy_update(unit)
    emit(:Summoned, unit)
    return true
  end
  
  def remove_unit(unit)
    @units.delete(unit.id)
    as = []
    for a in unit.artifacts
      next if as.include?(a)
      as.push(a)
      a.wielder = nil
      if unit.temp
        a.sprite.dispose
      else
        if a.completed && @empowered.include?(:uncombine)
          for n in a.get_base_stats[:components]
            give_artifact($artifacts[:name_map][n].new)
          end
          a.sprite.dispose
        else
          $artifact_tray.give(a.sprite, 0.5*$frames_per_second)
        end
      end
    end
    unit.clear_from_board()
    unit.current_hex = nil
    synergy_update(unit)
  end
  
  def give_aura(aura)
    @auras.push(aura)
    emit(:AuraChosen, aura)
    $my_auras.update if $my_auras
  end
  def remove_aura(aura)
    @auras.delete(aura.id)
    aura.clear_aura()
  end
  
  def give_artifact(a)
    a.prepare_sprite
  end
  
  def remove_artifact(a)
    @artifacts.delete(a)
  end
  
  def gain_xp(amount)
    return if @level >= 9
    @xp += amount
    emit(:XPGained)
    xp_to_level = $Level_xp[@level]
    if @xp >= xp_to_level
      @xp -= xp_to_level
      level_up()
    else
      @storefront.update_level
    end
  end
  
  def level_up
    @level += 1
    emit(:LevelUp)
    @storefront.update_level
  end
  
  def lose_life(amount)
    @life -= amount
    emit(:LostLife, amount)
    emit(:LifeChanged, -amount)
    emit(:Losing) if @life == 0
    $processor_status = :match_loss if @life == 0
    @storefront.update_life if @storefront
  end
  
  def gain_life(amount)
    return if amount <= 0
    @life += amount
    emit(:RecoveredLife, amount)
    emit(:LifeChanged, amount)
    @storefront.update_life if @storefront
  end
  
  def give_gold(amount, from)
    return if amount <= 0
    @gold += amount
    emit(:GainedGold, amount, from)
    @storefront.update_gold if @storefront
  end
  
  def spend_gold(amount)
    return true if amount < 0
    return false if amount > @gold
    @gold -= amount
    emit(:SpentGold, amount)
    @storefront.update_gold if @storefront
    return true
  end
  
  # expected income
  def calc_income
    streak_gold = $Streak_Base[@streak.abs().cap($Streak_Base.length-1)]
    streak_gold *= 2 if @synergy_handlers[:DRACONIC].level > 1
    streak_gold += 2 if @empowered.include?(:mining) && @streak > 0
    bg = @gold * 0.1
    if @empowered.include?(:tithe) && @opponent && @opponent.gold > @gold
      bg = @opponent.gold * 0.1
    end
    interest = (bg).floor().cap(@interest_cap)
    passive = 5
    win = 1
    
    if !@opponent || @opponent.is_a?(Minion_Player)
      passive = 0
      win = 0
    end
    
    return [streak_gold, interest, passive, win]
  end
  
  def grab_interest
    if @cached_interest
      hold = @cached_interest
      @cached_interest = nil
      return hold
    else
      return calc_income[1]
    end
  end
  
  # apply damage, win gold, cache passive income
  def round_wrap_up(loss_damage)
    adjust_streak(loss_damage == 0)
    ci = calc_income
    if loss_damage > 0
      lose_life(loss_damage)
    elsif !@opponent.is_a?(Minion_Player)
      @gold += 1
      emit(:GainedGold, 1)
      @round_gold = ci[2]
    end
    @round_gold += ci[0]
    if @empowered.include?(:tithe) && @opponent.gold > @gold
      @cached_interest = ci[1]
    end
  end
  
  # leveled values
  def units_allowed
    base = @level
    base += 1 if @impacts.include?(:AmbitionSlot)
    return base
  end
  
  def board_slots_used
    counter = 0
    if $processor_status == :combat
      for id, u in @units
        counter += u.board_slots if u.deployed
      end
    else
      for id, u in @units
        counter += u.board_slots unless u.is_benched?
      end
    end
    return counter
  end
  
  def board_slots_free
    return units_allowed - board_slots_used
  end
  
  # counters
  def adjust_streak(victory)
    if victory
      @streak = 0 if @streak < 0
      @streak += 1
      emit(:RoundWon, streak)
    else
      @streak = 0 if @streak > 0
      @streak -= 1
      emit(:RoundLost, streak)
    end
    local_emit(:RoundResolved, streak)
    emit(:SynergyUnlocked)
    @storefront.update_streak if @storefront
  end
  
  def full_bench_script(unit)
    # handle trying to add a unit to a full bench
  end
  
  # offer items to pick
  def present_artifacts(artifact_array, number_to_pick)
  end
  
  # handle loot drops
  def loot(sym, val)
  end
  
  def prepare_match
    for key, u in units
      # clear out combat-limited tokens and mind-controlled minions still kicking around
      if u.is_a?(Token) || (@id == 1 && u.is_a?(Minion)) || u.temp
        @units.delete(u.id)
        u.sprite.visible = false unless u.sprite.disposed?
        u.current_hex.battler = nil if u.current_hex
        u.current_hex = nil
      end
      unless u.is_benched?
        @deployed.push(u)
        u.deployed = true
      end
      u.starting_hex = u.current_hex
      u.init_ticker(true)
    end
    emit(:Deployed)
    # reset values
    for key, u in units
      u.damage_dealt = 0
      u.damage_taken = 0
      u.damage_healed = 0
    end
    @refresh_counter = 0
  end
  
  def move_to_free_hex(unit)
    board = @board
    hexline = @board.hexline.reverse()
    if @match && @match.board != @board
      board = @match.board
      hexline = board.hexline
    end
    for hid in hexline
      hex = board.board_map[hid]
      next if hex.battler
      next if hex.start_player == nil unless board != @board
      if hex.start_player.is_a?(Player_Battler) && hex.start_player != self && $processor_status != :combat_phase
        next
      end
      hex.set_battler(unit)
      return true
    end
    return false
  end
  
  def move_to_free_bench(unit)
    for h in @bench.board_map
      return if h.set_battler(unit)
    end
    return false
  end
  
  def synergy_update(unit)
    if unit.is_benched?
      for s in unit.synergies
        @synergy_handlers[s].remove_member(unit) if @synergy_handlers[s].members.include?(unit)
      end
    else
      for s in unit.synergies
        @synergy_handlers[s].add_member(unit) unless @synergy_handlers[s].members.include?(unit)
      end
    end
    @syn_tray.update if @syn_tray
    @storefront.update_sprites if @storefront
  end
  
  def units_named(name)
    us = []
    for id, u in @units
      us.push(u) if u.name == name
    end
    return us
  end
  
  def unit_counts(name)
    return units_named(name).length
  end
  
  def sacrifice(unit)
    return false if unit.owner != self
    old_hex = unit.current_hex
    unit.dead = true
    unit.clear_from_board
    @match.counters[:deaths] += 1
    unit.emit(:Died, unit, old_hex, nil)
    emit(:Sacrificed, unit)
    return true
  end
  
  def star_up_tiers(unit=nil)
    tiers = {}
    for id, u in @units
      next if u.level >= 3
      next if unit && u.star_id != unit.star_id
      unless tiers[u.star_id]
        tiers[u.star_id] = []
      end
      tiers[u.star_id].push(u)
    end
    return tiers
  end
  
  # check if any of our units can star up
  def star_up_check(unit=nil)
    tiers = star_up_tiers(unit)
    for id, t in tiers
      next unless t.length >= 3
      benched = []
      board = []
      for u in t
        if u.is_benched?
          benched.push(u)
        elsif $processor_status != :combat_phase
          board.push(u)
        end
      end
      eff_count = benched.length
      eff_count += 1 if board.length > 0
      next if eff_count < 3
      star_up_process(benched, board)
    end
  end
  
  # convert three units into a star up
  def star_up_process(benched, board)
    benched = benched.sort_by {|u| -u.artifacts.length}
    board = board.sort_by {|u| -u.artifacts.length}
    primary = nil
    secondary = []
    # figure out the one that gets to live
    if board.length > 0
      # upgrade the one on the board
      primary = board[0]
    else
      # upgrade the one with the most artifacts or whoever if they're tied
      primary = benched[0]
      benched.delete(primary)
    end
    # figure out the two that die
    if benched.length < 2
      # invalid match got sent in
      return
    else
      benched.reverse
      secondary = [benched[0], benched[1]]
    end
    comb = secondary + [primary]
    # animation
    for i in 0..2
      light = new_animation_sprite
      light.bitmap = RPG::Cache.icon("Ability/Hexes/light.png")
      light.x = comb[i].current_hex.pixel_x
      light.y = comb[i].current_hex.pixel_y
      light.z = comb[i].sprite.z + 30
      light.opacity = 128
      light.add_fade_to(255, 0.3*fps)
      light.add_fade_to(0, 0.3*fps)
      light.add_dispose
    end
    for s in secondary
      primary.empowered = primary.empowered + s.empowered
      remove_unit(s)
    end
    primary.level_up
    star_up_check(primary)
  end
  
    # Buffs
  def add_buff(buff)
    @buffs[buff.id] = buff
  end
    
  def remove_buff(buff)
    @buffs.delete(buff.id)
  end
  
  # Impacts
  def add_impact(impact)
    @impacts[impact.id] = [] unless @impacts[impact.id]
    return if @impacts[impact.id].include?(impact)
    emit(:PlayerGainingImpact, impact)
    @impacts[impact.id].push(impact)
  end
  
  def remove_impact(impact)
    return unless @impacts[impact.id]
    return unless @impacts[impact.id].include?(impact)
    emit(:PlayerLosingImpact, impact)
    @impacts[impact.id].delete(impact)
    @impacts.delete(impact.id) if @impacts[impact.id].empty?
  end
  
  def has_aura?(aclass)
    for a in @auras
      return true if a.is_a?(aclass)
    end
    return false
  end

  
end