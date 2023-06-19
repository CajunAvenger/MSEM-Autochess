# Warrior
# @2/4/6/8
# Your whole team gains increasing amounts of power.
# Warriors get twice as much

class Synergy_Warrior < Synergy
  def breakpoints
    return [2, 4, 6, 8]
  end
  
  def key
    return :WARRIOR
  end
  
  def sprite
    return "Warrior"
  end
  
  def blanketer
    return true
  end
  
  def info_text(lv=level)
    return {
      :name => "Warrior",
      :breaks => breakpoints,
      :level => lv,
      :header => "Your whole team gains increasing~" +
      "power. Warriors gain double.",
      :blocks => [
        "15% increased power.",
        "30% increased power.",
        "45% increased power.",
        "60% increased power."
      ],
      :members => @member_names
    }
  end
  
  def apply(unit)
    return if @impacting.include?(unit.id)
    efs = []
    efs.push(Impact_SynScale.new(:POWER_MULTI, 0.15, self))
    efs.push(Impact_SynScale.new(:POWER_MULTI, 0.15, self, :WARRIOR))
    @impacting[unit.id] = Buff_Eternal.new(self, unit, efs, "Warrior Rage")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end
end
register_synergy(Synergy_Warrior, :WARRIOR)