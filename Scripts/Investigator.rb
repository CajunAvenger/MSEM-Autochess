# Investigator
# @2/4/6
# Your whole team gains increasing amounts of archive.

class Synergy_Investigator < Synergy
  def key
    return :INVESTIGATOR
  end
  
  def breakpoints
    return [2, 4, 6]
  end
  
  def sprite
    return "Investigator"
  end
  
  def info_text(lv=level)
    return {
      :name => "Investigator",
      :breaks => breakpoints,
      :level => lv,
      :header => "Your whole team gains increasing~" +
      "amounts of archive.",
      :blocks => [
        "20% increased archive.",
        "40% increased archive.",
        "60% increased archive."
      ],
      :bm => 5,
      :members => @member_names
    }
  end
  
  def blanketer
    return true
  end
  
  def apply(unit)
    return if @impacting.include?(unit.id)
    efs = [
      Impact_SynScale.new(:ARCHIVE_MULTI, 0.2, self),
      Impact_AuraSynScale.new(:ARCHIVE_MULTI, 0.2, self, RiteOfLostTimelines, true)
    ]
    @impacting[unit.id] = Buff_Eternal.new(self, unit, efs, "All Points Bulletin")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end

end
register_synergy(Synergy_Investigator, :INVESTIGATOR)