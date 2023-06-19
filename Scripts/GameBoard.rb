# A player's side of the board or their bench
class GameBoard
  attr_reader :gm               # the game master
  attr_reader :board_map        # the map of hexes
  attr_reader :player           # the player this belongs to
  attr_reader :hexline          # the order hexes were created, to reverse
  attr_accessor :graveyard      # units dead on this GameBoard
  attr_accessor :visiting       # units dead on this GameBoard
  attr_reader :x
  attr_reader :y
  
  def initialize(player, bench=false)
    @gm = player.gm
    @x = @gm.game_settings[:bench]
    @y = 1
    unless bench
      @x = @gm.game_settings[:width]
      @y = @gm.game_settings[:height]*2 + @gm.game_settings[:no_mans]
    end
    @player = player
    build_board(@x, @y, bench)
    @graveyard = []
  end
  
  def build_board(x, y, bench)
    @board_map = {}
    lead_hex = nil
    lead_y = -1
    dir = 1
    dir = -1 if y%2 == 1
    ind = -1*dir
    sp = nil
    @hexline = []
    r = @gm.game_settings[:height]
    for i in 0..y-1
      prev_hex = nil
      ind = -1*ind
      sp = @player if !sp && i == r
      sp = @player if !sp && bench
      for j in 0..x-1
        hex_hash = {
          :bench => bench,
          :player => sp,
          :row => i+1,
          :x => j,
          :y => i,
          :indent => ind,
          :board => self
        }
        hex = Hex.new(hex_hash)
        @hexline.push(hex.id)
        @board_map[hex.id] = hex
        # save this hex to connect to the next one
        if prev_hex == nil
          prev_hex = hex
        else
          # connect to the previous hex and back
          hex.set_left(prev_hex)
          prev_hex.set_right(hex)
          # if the right hand hex has a top right hex set
          if prev_hex.top_right_hex != nil
            # set this hex's top left to that one
            hex.set_top_left(prev_hex.top_right_hex)
            # connect that back
            prev_hex.top_right_hex.set_bottom_right(hex)
            if hex.top_left_hex.right_hex
              # that hex's right is this hexes top left
              hex.top_left_hex.right_hex.set_bottom_left(hex)
              # and connect back
              hex.set_top_right(hex.top_left_hex.right_hex)
            end
          end
          prev_hex = hex
        end        
        # connect to top row
        if lead_hex == nil
          lead_hex = hex
          lead_y = i
        end
        if i > lead_y
          # set lead_hex as top left (dir -1) or top right (dir 1)
          if dir == -1
            # connect right-edge x=0 to left-edge x=0 above
            hex.set_top_left(lead_hex) 
            # connect left-edge x=0 to right-edge x=0 below
            lead_hex.set_bottom_right(hex)
            # connect right-edge x=0 to left-edge x=1
            hex.set_top_right(lead_hex.right_hex)
            # connect left-edge x=1 to right-edge x=0
            lead_hex.right_hex.set_bottom_left(hex)
          else
            # connect left-edge x=0 to right-edge x=0
            hex.set_top_right(lead_hex)
            # connect right-edge x=0 to left-edge x=0
            lead_hex.set_bottom_left(hex)
          end
          lead_hex = hex
          lead_y = i
          dir = -1*dir
        end
      end
    end
  end
  
  def add_opponent(visiting)
    @visiting = visiting
    @opp_cover.dispose if @opp_cover
    hl = @hexline.length
    for h, hex in @visiting.board_map
      next unless hex.battler
      ind = @hexline.index(hex.id)
      flip_id = ("Hex" + (@x-hex.id_x-1).to_s + (@y-hex.id_y-1).to_s).to_sym#@hexline[hl-ind]
      flip_hex = @board_map[flip_id]
      flip_hex.battler = hex.battler
      flip_hex.battler.update_hex(flip_hex, true)
    end
    @player.opponent = visiting.player
    @player.opponent.opponent = @player
  end
  
  def preview_opp(visiting)
    unless @player.empowered.include?(:foresight) || visiting.empowered.include?(:announcing)
      @opp_cover = new_hex_sprite
      @opp_cover.bitmap = Bitmap.new("Graphics/Icons/Infobox_name.png")
      @opp_cover.x = 4
      @opp_cover.y = 0
      @opp_cover.z = 9001
    end
    @opp_name_badge = new_hex_sprite
    @opp_name_badge.bitmap = Bitmap.new("Graphics/Icons/Infobox_name.png")
    @opp_name_badge.x = 4
    @opp_name_badge.y = 0
    @opp_name_badge.z = 9000
    @opp_name_badge.bitmap.font.name = "Fontin"
    @opp_name_badge.bitmap.font.color.set(255,255,255)
    @opp_name_badge.bitmap.shrink_to(visiting.name, 110)
    @opp_name_badge.bitmap.draw_text(0, 0, 120, 32, visiting.name, 1)
  end
  
  def end_round
    for h, hex in @board_map
      next unless hex.battler
      @graveyard.push(hex.battler)
      hex.battler = nil
    end
    for b in @graveyard
      if b.owner == @player
        b.reset_state
      else
        b.current_hex = nil
        b.sprite.vis(false)
      end
    end
    @visiting = nil
    @player.opponent.match = nil
    @player.opponent.opponent = nil
    @player.match = nil
    @player.opponent = nil
    @opp_name_badge.dispose if @opp_name_badge
  end
  
end