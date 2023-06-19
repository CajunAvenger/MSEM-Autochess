class Monster_Player < Player_Battler
  
  def initialize(player)
    super(player.id + 10)
    for h in player.board
      next unless h.battler
      my_hex = @board[h.id]
      @units.push(h.battler.dupe_for(my_hex, self))
    end
    for h in player.bench
      next unless h.battler
      my_hex = @bench[h.id]
      @units.push(h.battler.dupe_for(my_hex, self))
    end
  end
  
end