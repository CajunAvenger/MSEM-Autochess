# a PvE minion opponent
class Minion_Player < Player_Battler
  attr_accessor :boxes_dropped
  def initialize(round_major, round_minor, gm)
    super(2, gm)
    @boxes_dropped = 0
    case round_minor
    when 1
      # two melee
=begin
      @name = "Gunslingers"
      give_unit(Heddwyn.new(), @board.board_map[:Hex24])
      give_unit(Marianne.new(), @board.board_map[:Hex46])
      for id, u in @units
        synergy_update(u)
      end
      give_unit(Haide.new(), @board.board_map[:Hex37])
      give_unit(Eli.new(), @board.board_map[:Hex54])
      give_unit(Azun.new(), @board.board_map[:Hex25])
      give_unit(Mannequin.new(), @board.board_map[:Hex07])
      give_unit(Mannequin.new(), @board.board_map[:Hex67])
      give_unit(Mannequin.new(), @board.board_map[:Hex34])
      give_unit(Mannequin.new(), @board.board_map[:Hex25])
      give_unit(Mannequin.new(), @board.board_map[:Hex45])
      give_unit(Mannequin.new(), @board.board_map[:Hex36])
=end
      give_unit(Mannequin.new(), @board.board_map[:Hex66])
      give_unit(Mannequin.new(), @board.board_map[:Hex54])
      @name = "Mannequins"
      @gold = 100
      
    when 2
      # two melee, one ranged
      @name = "Hawk n Quins"
      give_unit(Mannequin.new(), @board.board_map[:Hex44])
      give_unit(Mannequin.new(), @board.board_map[:Hex54])
      give_unit(Hawk.new(), @board.board_map[:Hex46])
    when 3
      # two melee, one ranged
      @name = "Hawks n Quins"
      give_unit(Mannequin.new(), @board.board_map[:Hex44])
      give_unit(Mannequin.new(), @board.board_map[:Hex54])
      give_unit(Hawk.new(), @board.board_map[:Hex46])
      give_unit(Hawk.new(), @board.board_map[:Hex27])
    when 4
      # two brutes
      @name = "2Brute4U"
      give_unit(Brute.new(self, 2), @board.board_map[:Hex44])
      give_unit(Brute.new(self, 2), @board.board_map[:Hex54])
    end
  end
end