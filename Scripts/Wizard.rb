# Wizard
# @2/4/6/8
# Your whole team gains increasing amounts of mana_amp.
# Wizards get twice as much

class Synergy_Wizard < Synergy
  def breakpoints
    return [2, 4, 6, 8]
  end
  
  def key
    return :WIZARD
  end
  
  def sprite
    return "Wizard"
  end
  
  def blanketer
    return true
  end
  
  def info_text(lv=level)
    return {
      :name => "Wizard",
      :breaks => breakpoints,
      :level => lv,
      :header => "Your whole team gains increasing~" +
      "mana amp. Wizards gain double.",
      :blocks => [
        "15% increased mana amp.",
        "30% increased mana amp.",
        "45% increased mana amp.",
        "60% increased mana amp."
      ],
      :members => @member_names
    }
  end
  
  def apply(unit)
    return if @impacting.include?(unit.id)
    efs = []
    efs.push(Impact_SynScale.new(:MANA_AMP_MULTI, 0.15, self))
    efs.push(Impact_SynScale.new(:MANA_AMP_MULTI, 0.15, self, :WIZARD))
    @impacting[unit.id] = Buff_Eternal.new(self, unit, efs, "Rising Tide")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end
end
register_synergy(Synergy_Wizard, :WIZARD)