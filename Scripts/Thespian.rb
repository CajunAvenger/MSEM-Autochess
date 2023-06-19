# Thespian
# @3
# Your Thespians are cloaked for the first few moments of combat.
# @5
# Your bench is no longer visible to your opponents.
class Synergy_Thespian < Synergy
  def key
    return :THESPIAN
  end
  
  def breakpoints
    return [3, 5]
  end
  
  def sprite
    return "Thespian"
  end
  
  def info_text(lv=level)
    return {
      :name => "Thespian",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "Thespians are cloaked for the~" + 
        "first moments of combat.",
        "Your bench is hidden from~" +
        "opponents."
      ],
      :bm => 4,
      :multiblock => {2 => [1]},
      :members => @member_names
    }
  end
  
  def deployer
    return true
  end
  
  def match_apply(u)
    Buff_Timed.new(self, u, Impact.new(:CLOAK, 1), 1, "Opening Night") if level > 0
  end
  
  def init_match_listeners
    for u in @members
      match_apply(u)
    end
  end
end
register_synergy(Synergy_Thespian, :THESPIAN)