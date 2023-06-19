# Draconic
# @3
# Your Draconic units gain stats based on your gold reserves.
# @5
# And you double the bonus gold for win/loss streaks. 
# Kunal: Power. Boxue: Archive. Flynn: Ward. Iviana: Mana amp.
class Synergy_Draconic < Synergy
  
  def key
    return :DRACONIC
  end
  
  def breakpoints
    return [3, 5]
  end
  
  def sprite
    return "Draconic"
  end
  
  def info_text(lv=level)
    return {
      :name => "Draconic",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "Draconic units gain stats based~" + 
        "on your gold reserves.~" + 
        "Kunal: Power~" +
        "Boxue: Archive~" +
        "Flynn: Ward~" + 
        "Iviana: Mana amp.",
        "You get double gold for streaks."
      ],
      :multiblock => {2 => [1]},
      :bm => "7",
      :members => @member_names
    }
  end
  
  def add_member(member, leech=false)
    super
    imps = []
    case member.name
    when "Kunal"
      imps.push(Impact_Draconic.new(:POWER_MULTI, 1, self))
    when "Boxue"
      imps.push(Impact_Draconic.new(:ARCHIVE_MULTI, 1, self))
    when "Flynn"
      imps.push(Impact_Draconic.new(:WARD_MULTI, 1, self))
    when "Iviana"
      imps.push(Impact_Draconic.new(:MANA_AMP_MULTI, 1, self))
    end
    Buff_Eternal.new(self, member, imps, "Dragon's Hoard", ["Synergy"])
  end
  
  def buff_visible?(buff)
   return level() > 0
  end
end
register_synergy(Synergy_Draconic, :DRACONIC)