# Assassin
# @Innate
# Assassins jump to the enemy backline.
# @2
# Assassins gain increased multistrike chance.
# @4
# Assassins gain increased multistrike chance.

class Synergy_Assassin < Synergy
  
  def key
    return :ASSASSIN
  end
  
  def breakpoints
    return [2, 4]
  end
  
  def has_innate?
    return true
  end
  
  def sprite
    return "Assassin"
  end
  
  def info_text(lv=level)
    return {
      :name => "Assassin",
      :breaks => breakpoints,
      :level => lv,
      :header => "Innate: Assassins jump to enemy's~" +
      "back line when combat starts.",
      :blocks => [
        "Assassins get +15% chance~" +
        "to multistrike.",
        "Assassins get +30% chance~" +
        "to multistrike.",
      ],
      :members => @member_names
    }
  end

  def deployer
    return true
  end
  
  def blanketer
    return true
  end
  
  def init_match_listeners
    return unless @member_names.length > 0
    jump = Proc.new do |listen|
      temp = listen.subscriber.owner.deployed[0].current_hex
      board = listen.host.board.board_map
      opp_back = 0
      opp_inc = 1
      if temp.row_number < 5
        opp_back = listen.host.board.y - 1
        opp_inc = -1
      end
      ids = [0, opp_back];
      for u in listen.subscriber.owner.deployed
        next unless u.synergies.include?(:ASSASSIN)
        # move to opp backrow, try to keep same x value
        test = ("Hex" + u.current_hex.id_x.to_s + opp_back.to_s).to_sym
        moved = board[test].set_battler(u)
        # if that hex is filled, throw us somewhere
        # prioritize back row
        until moved
          h_sym = ("Hex" + ids[0].to_s + ids[1].to_s).to_sym
          hex = board[h_sym]
          # break if we hit an illegal hex or one of our own hexes
          break unless hex
          break if hex.start_player == listen.subscriber.owner
          moved = hex.set_battler(u)
          ids[0] += 1
          if ids[0] >= listen.host.board.x
            ids[0] = 0
            ids[1] += opp_inc
          end
        end
      end
    end
    l = gen_subscription_to(@owner.match, :RoundStart, jump)
    l.fragile = true
  end
  
  def apply(unit)
    return unless unit.synergies.include?(:ASSASSIN)
    return if @impacting.include?(unit.id)
    efs = Impact_SynScale.new(:MULTI, 15, self, :ASSASSIN)
    @impacting[unit.id] = Buff_Eternal.new(self, unit, efs, "Double Tap")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end
  
end
register_synergy(Synergy_Assassin, :ASSASSIN)