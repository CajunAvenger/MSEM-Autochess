# Alara
# @3
# For every non-Alara synergy you have active, Alara units gain
# 100 health, 10 power, 5 mana-amp, 5 toughness, 5 ward
# @5
# Alara units get doubled bonuses
class Synergy_Alara < Synergy
  
  def key
    return :ALARA
  end
  
  def breakpoints
    return [3, 5]
  end
  
  def sprite
    return "Alara"
  end
  
  def info_text(lv=level)
    return {
      :name => "Alara",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "Your Alara units get +100 life,~" +
        "+10 power, +5 mana amp, ward,~" + 
        "and toughness for each other~" +
        "synergy you have active.",
        "Alara bonus is doubled."
      ],
      :multiblock => {2 => [1]},
      :bm => 5,
      :members => @member_names
    }
  end
  
  def blanketer
    return true
  end
  
  def apply(unit)
    return unless unit.synergies.include?(:ALARA)
    return if @impacting.include?(unit.id)
    # control the multiplier for all the stats
    stack_imp = Impact_SynCounter.new(:AlaraBuff, 1, [:ALARA], self, 1, true)
    efs = []
    efs.push(stack_imp)
    efs.push(Impact_Linked.new(:MAX_LIFE, 100, stack_imp))
    efs.push(Impact_Linked.new(:POWER, 10, stack_imp))
    efs.push(Impact_Linked.new(:MANA_AMP, 5, stack_imp))
    efs.push(Impact_Linked.new(:TOUGHNESS, 5, stack_imp))
    efs.push(Impact_Linked.new(:WARD, 5, stack_imp))
    abuff = Buff_Eternal.new(self, unit, efs, "Conflux")
    @impacting[unit.id] = abuff
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end
  
end
register_synergy(Synergy_Alara, :ALARA)