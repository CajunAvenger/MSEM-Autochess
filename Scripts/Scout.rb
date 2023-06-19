# Scout
# Innate
# Scouts get +2 range
# @2/4/6/8
# Your Scouts gain increasing haste and archive for each hex between them
#  and their target
class Synergy_Scout < Synergy
  def key
    return :SCOUT
  end
  
  def breakpoints
    return [2, 4, 6, 8]
  end
  
  def has_innate?
    return true
  end
  
  def sprite
    return "Scout"
  end
  
  
  def info_text(lv=level)
    return {
      :name => "Scout",
      :breaks => breakpoints,
      :level => lv,
      :header => "Innate: Your Scouts get +2 range.",
      :blocks => [
        "Scouts gain +10% haste and~" + 
        "archive for each hex between~" + 
        "them and their target.",
        "+20% haste and archive.",
        "+30% haste and archive.",
        "+40% haste and archive."
      ],
      :bm => 7,
      :members => @member_names
    }
  end
  
  def blanketer
    return true
  end

  def apply(unit)
    return if @impacting.include?(unit.id)
    efs = []
    efs.push(Impact_SynCheck_Harsh.new(:RANGE, 2, :SCOUT, self))
    efs.push(Impact_Scout.new(:HASTE_MULTI, 0.1, self))
    efs.push(Impact_Scout.new(:ARCHIVE_MULTI, 0.1, self))
    Buff_Eternal.new(self, unit, efs, "Eyes on the Back of their Heads")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end
end
register_synergy(Synergy_Scout, :SCOUT)