class Match < Emitter
  attr_reader :player1
  attr_reader :player2
  attr_reader :board
  attr_reader :winner
  attr_reader :id
  attr_reader :timer
  attr_reader :round
  attr_accessor :status
  attr_accessor :counters
  attr_reader :combat_frames
  attr_reader :max_combat_frames
  
  def initialize(player1, player2, round)
    @player1 = player1
    @player2 = player2
    @player1.match = self
    @player2.match = self
    @round = round
    @board = @player1.board
    @board.preview_opp(@player2)
    @id = "match" + get_match_id.to_s
    @listening_to_me = {}
    @my_listener_cache = []
    @upticker = 0
    @cache = Time.now.to_f
    @status = :setup
    @timer = 0
    @combat_frames = 0
    @max_combat_frames = 10*$frames_per_second
    srand()
    $timer = Timer.new(self)
    @counters = {
      :deaths => 0
    }
    for a in player1.refresh_aoes
      a.match_listener
    end
    for a in player2.refresh_aoes
      a.match_listener
    end
    player1.local_emit(:MatchBuilt)
    player2.local_emit(:MatchBuilt)
  end
  
  def main
    if @timer > 0
      @timer -= 1
      @timer_sprite.update if @timer_sprite
      return
    end
    case @status
    when :begin_planning
      # we get :begin_planning from parallel_processor
      # loop for 30s for planning, buying, etc
      # set up minions now
      @status = :planning
      @timer = 10 * $frames_per_second
      @timer = 15 * $frames_per_second if @round.name == "1-1"
      
      @timer_sprite = TimerBar.new($viewport)
      @timer_sprite.set_time(@timer)
      if @player2.is_a?(Minion_Player)
        @board.add_opponent(@player2.board)
        @player2.deployed = []
        @player2.prepare_match
      end
      #console.log("move to planning")
    when :planning
      # once the planning timer is up, move to combat
      # delay a second if an opponent is setting up
      $processor_status = :combat_phase
      unless @player2.is_a?(Minion_Player)
        @board.add_opponent(@player2.board)
        @player2.deployed = []
        @player2.prepare_match
        @timer = 0.6*$frames_per_second
      end
      #console.log("preparing match")
      Mouse.drop(true) if Mouse.holding?.is_a?(Unit)
      @player1.deployed = []
      @player1.prepare_match
      @player1.emit(:SynergyLocked)
      @player2.emit(:SynergyLocked)
      @status = :running
      @timer_sprite.dispose
      @timer_sprite = TimerBar.new($viewport)
      @timer_sprite.set_time(@max_combat_frames)
      #console.log("emitting round start")
      emit(:RoundStart)
      # delay long enough for assassins to move
      @timer += 0.4*$frames_per_second
    when :running
      # loop the combat process until it breaks us out with :cleanup
      combat
      @timer_sprite.update
    when :cleanup
      # the break timed us out for the remainder of the round time
      # now clear the GameBoard and send us on our way
      @player1.board.end_round
      emit(:RoundEnd)
      for id, s in @player1.synergy_handlers
        s.round_reset
      end
      for id, s in @player2.synergy_handlers
        s.round_reset
      end
      $processor_status = :begin_round unless $processor_status == :match_loss
      @status = :done
      silence_listeners
    end
  end

  def combat
    # calc $tick_loops times to give illusion of better execution rate
    #console.log("emit frame")
    emit(:Frame, @combat_frames)
    emit(:Quarter, @combat_frames) if @combat_frames % $quarter_second == 0
    for i in 1..$tick_loops
      #console.log("tick")
      emit(:Tick, @combat_frames)     # emit once a Tick
      #console.log("ticked")
      ability_ready = []             # battlers ready to use ability
      attack_ready = []              # battlers ready to attack
      active = @player1.deployed + @player2.deployed
      active.reverse if i%2 == 0
      for b in active                # only check those still deployed
        cc = b.clock_ticker()
        attack_ready.push(b) if cc == true
        unless cc == :stunned
          ability_ready.push(b) if b.mana_ticker()
        end
      end
      # sort for ties?
      #console.log("abils")
      for b in ability_ready do
        #console.log(b.id + " trying spell")
        b.try_ability()
      end
      #console.log("attacks")
      for b in attack_ready do
        #console.log(b.id + " trying attack")
        b.try_attack()
      end
      
      #console.log("check")
      # check if combat's over
      if @player2.deployed.length == 0 || @player1.deployed.length == 0 || @combat_frames >= @max_combat_frames
        #console.log("end of combat")
        @timer = (@max_combat_frames - @combat_frames - 1).low_cap(0)
        @status = :cleanup
        # clear the animations, leave the hexes for now
        for sprite in $scene.spriteset.anim_sprites
          sch = sprite.add_schedule()
          sprite.add_wait(0.5*$frames_per_second, sch)
          sprite.add_dispose(sch)
        end
        # damage dealt by remaining damage_array[level-1][cost-1] units
        damage_array = [
          [1, 2, 2, 3, 4, 4, 4],
          [2, 3, 4, 5, 6, 6, 6],
          [4, 5, 6, 7, 8, 8, 8]  
        ]
        ps = [@player1, @player2]
        for p in ps
          loss_damage = 0
          for u in p.deployed
            loss_damage += damage_array[u.level-1][u.get_base_stats[:cost]]
            loss_damage += u.bonus_loss_damage
          end
          loss_damage += 2 if loss_damage > 0
          # its a win if you take 0 loss_damage
          p.opponent.round_wrap_up(loss_damage)
        end
        return
      end
      #console.log("checked")
    end
    # after our Ticks, count the frame
    @combat_frames += 1
    #console.log("end of frame")
  end
  
  def other_player(pl)
    return @player2 if pl == @player1
    return @player1 if pl == @player2
    return nil
  end
  
end