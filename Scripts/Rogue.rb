# Rogue
# @2/4/6
# Your whole team gains increasing amounts of haste.

class Synergy_Rogue < Synergy
  
  def key
    return :ROGUE
  end
  
  def breakpoints
    return [2, 4, 6]
  end
  
  def sprite
    return "Rogue"
  end
  
  def blanketer
    return true
  end
  
  def info_text(lv=level)
    return {
      :name => "Rogue",
      :breaks => breakpoints,
      :level => lv,
      :header => "Your whole team gains increasing~" +
      "amounts of haste.",
      :blocks => [
        "20% increased haste.",
        "40% increased haste.",
        "60% increased haste."
      ],
      :bm => 5,
      :members => @member_names
    }
  end
  
  def add_member(m, l=false)
    super
    console.log(level)
  end
  
  def apply(unit)
    return if @impacting.include?(unit.id)
    efs = Impact_SynScale.new(:HASTE_MULTI, 0.2, self)
    @impacting[unit.id] = Buff_Eternal.new(self, unit, efs, "Tip Toe Shape")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end
  
end
register_synergy(Synergy_Rogue, :ROGUE)