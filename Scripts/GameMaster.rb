$lobby_round = {:type => :lobby, :time => 100}
$lobby_round_short = {:type => :lobby_2, :time => 60}
$monster_round = {:type => :vs_monster, :time => 60}
$player_round = {:type => :vs_player, :time => 60}
$starter_round = [$lobby_round, $monster_round, $monster_round, $monster_round]
$main_round = [
  $player_round,
  $player_round,
  $player_round,
  $lobby_round_short,
  $player_round,
  $player_round,
  $monster_round
]
$default_settings = {
  :width => 7,
  :height => 4,
  :no_mans => 0,
  :bench => 9,
  :rounds => [$starter_round, $main_round]
}

$starter_round = [$monster_round, $monster_round, $monster_round, $monster_round]
$default_settings = {
  :width => 7,
  :height => 4,
  :no_mans => 0,
  :bench => 9,
  :rounds => [$starter_round]
}
# $game_master is the instance of this class
class GameMaster < Emitter
  attr_reader :curret_round
  attr_reader :game_settings
  attr_reader :players
  attr_reader :main_round
  attr_reader :sub_round
  
  def initialize(player_count, game_settings)
   @game_settings = game_settings
   @players = []
   @players.push(Player_Battler.new(1, self))
=begin
    monster_board = GameBoard.new(nil, false, true)
    $hexline = monster_board.hexline
=end
    @main_round = 1
    @sub_round = 0
  end
  
  def next_round
    
    if @game_settings[:rounds][@main_round-1].length > @sub_round
      @sub_round += 1
    elsif @game_settings[:rounds].length > @main_round
      @main_round += 1
    else
      $processor_status = :match_victory
    end
    
    unless $processor_status == :match_victory
      for p in @players
        if p.is_a?(Minion_Player)
          @players.delete(p)
        elsif p.storefront
          console.log("clear tax")
          p.storefront.round_tax = 0
        end
      end
      @current_round = Round.new(@main_round, @sub_round, self)
    end
    
  end
  
  def hex_from_mouse(x_pix, y_pix)
    info = hex_id_from_coord(x_pix, y_pix)
    return nil unless info
    board = $player.board
    board = $player.bench if info[0] == :bottom_bench
    return board.board_map[info[1]]
  end
  
  # get a hex id from screen pixel points
  def hex_id_from_coord(x_pix, y_pix)
    # not accounting for bench
    xmin = $board_start_x - $hex_indent
    xmax = $board_start_x + $hex_indent + @game_settings[:width] * $hex_width
    ymin = $board_start_y
  
    y_id = nil  # the y index of the chosen hex
    x_id = nil  # the x index of the chosen hex
    # use mod to figure out where we are
    x_perc = nil  # the mod percentage along the x coord
    y_perc = nil  # the mod percentage along the y coord
    y_sub_perc = nil  # the mod percentage along the y coord on a hex
    x_rcn = nil  # the recontexted x coordinate
    y_rcn = y_pix - ymin - 16 # the recontexted y coordinate
    radi = Math::PI / 2
    offs = -1
    if @game_settings[:height]%2 == 1
      offs = 1
    end
    # Are we on the opp bench?
    if y_pix.between?($bench_y[2], $bench_y[2]+$hex_width)
      # this is the opponent's bench
      y_id = -2
    elsif y_pix.between?($bench_y[1], $bench_y[1]+$hex_width)
      # this is our bench
      y_id = -1
    elsif !x_pix.between?(xmin, xmax)
      # not on the board
      y_id = nil
    elsif y_rcn < 0
      # this is the top jag of the board
      y_id = 0
    else
      # this is somewhere on the board
      test = (y_rcn / $hex_drop).floor
      y_perc = y_rcn % $hex_drop
      if y_perc < 32
        # we're in the reliable section
        y_id = test
      else
        # we're in the ambiguous section
        # either test.floor or .ceil depending on x_pix
        indent_dir = offs*Math.sin((2*test-1)*radi)
        x_edge = $board_start_x + indent_dir*$hex_indent
        x_rcn = x_pix - x_edge
        x_perc = x_rcn % $hex_width
        y_sub_perc = y_perc - 32
        x_sub_perc = x_perc
        x_sub_perc -= 32 if x_sub_perc >= 32
        if y_perc > x_sub_perc/2
          # we're on the bottom hex
          y_id = test+1
        else
          # we're on a top hex
          y_id = test
        end
      end
    end
    return nil unless y_id # not on the board
    # now use the y_id to get x_rcn to get x_id
    indent_dir = offs*Math.sin((2*y_id-1)*radi)
    case y_id
    when -2
      x_edge = $bench_x[2]
    when -1
      x_edge = $bench_x[1]
    else
      x_edge = $board_start_x + indent_dir*$hex_indent
    end
    x_rcn = x_pix - x_edge
    x_id = (x_rcn / $hex_width).floor
    return nil if x_id < 0 # not on the board
    map = :board
    map = :top_bench if y_id == -2
    map = :bottom_bench if y_id == -1
    y_id = 0 if y_id < 0
    return [map, ("Hex" + x_id.to_s + y_id.to_s).to_sym]
  end
  
end