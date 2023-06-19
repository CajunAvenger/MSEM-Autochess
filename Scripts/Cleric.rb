# Cleric
# @2/3/4/5
# Your whole team gains increasing amounts of max life.

class Synergy_Cleric < Synergy
  def key
    return :CLERIC
  end
  
  def breakpoints
    return [2, 3, 4, 5]
  end
  
  def sprite
    return "Cleric"
  end
  
  def info_text(lv=level)
    return {
      :name => "Cleric",
      :breaks => breakpoints,
      :level => lv,
      :header => "Your whole team gains increasing~" +
      "amounts of max life.",
      :blocks => [
        "+30 max life.",
        "+60 max life.",
        "+90 max life.",
        "+120 max life."
      ],
      :members => @member_names
    }
  end
  
  def blanketer
    return true
  end
  
  def apply(unit)
    return if @impacting.include?(unit.id)
    efs = Impact_SynScale.new(:MAX_LIFE, 30, self)
    @impacting[unit.id] = Buff_Eternal.new(self, unit, efs, "Clerical Armor")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end
  
end
register_synergy(Synergy_Cleric, :CLERIC)