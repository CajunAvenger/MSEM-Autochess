class Round < Emitter
  attr_reader :name             # name of this round, "1-1"
  attr_reader :round_type       # :lobby, :vs_monster, :vs_player
  attr_reader :matches          # current matches underway
  attr_reader :main_n
  attr_reader :sub_n
  
  def initialize(main_n, sub_n, gm)
    @listening_to_me = {}
    @my_listener_cache = []
    @main_n = main_n
    @sub_n = sub_n
    @name = @main_n.to_s + "-" + @sub_n.to_s
    @gm = gm
    @matches = []
    mcap = @gm.game_settings[:rounds].length-1
    mcap = @main_n-1 unless @main_n-1 > mcap
    major_round = @gm.game_settings[:rounds][mcap]
    ncap = major_round.length-1
    ncap = @sub_n-1 unless @sub_n-1 > ncap
    major_round = @gm.game_settings[:rounds][mcap][ncap]
    @round_type = major_round[:type]
    @time = major_round[:time]
    
    if @round_type == :lobby
      
    else
      @matches = []
      @matches = pair_monsters if @round_type == :vs_monster
      @matches = pair_players if @round_type == :vs_player
      start_matches
    end
  end
  
  def pair_players
    pairs = []
    players = []
    for p in @gm.players
      players.push(p) unless p.life < 1
    end
    #return players if players.length == 2
    
    # later on this will want to pair up based on hp
    # but for now just pairing at random
    players = players.shuffle()
    if players.length % 2 == 1
      mp = Monster_Player.new(players.first())
      players.push(mp)
    end
    for i in 0..(players.length/2)-1 do
      pairs.push([players[2*i], players[2*i+1]])
    end
    return pairs
  end
  
  def pair_monsters
    pairs = []
    players = []
    for p in @gm.players
      players.push(p) unless p.life < 1
    end
    for p in players do
      pairs.push([p, Minion_Player.new(@main_n, @sub_n, @gm)])
    end
    return pairs
  end
  
  def start_matches
    for m in @matches
      Match.new(m[0], m[1], self)
    end
  end
  
  def starting_status
    if @round_type == :draft
      $processor_status = :draft
    else
      $processor_status = :planning_phase_begin
    end
  end
  
end