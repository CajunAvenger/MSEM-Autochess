# Morninglight
# @2
# Your Morninglight planeswalkers gain
#  bonus mana amp and life scaling with your win streak.
class Synergy_Morninglight < Synergy
  
  def key
    return :MORNINGLIGHT
  end
  
  def breakpoints
    return [2]
  end
  
  def sprite
    return "Morninglight"
  end
  
  def info_text(lv=level)
    return {
      :name => "Morninglight",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "Your Morninglight planeswalkers~" +
        "gain bonus mana amp and life~" +
        "scaling with your win streak:~" +
        "+" + (10*@owner.streak).to_s + " mana amp.~" +
        "+" + (1+(0.2*@owner.streak)).to_s + "x max life."
      ],
      :bm => 5,
      :members => @member_names
    }
  end
  
  def add_member(member, leech=false)
    super
    imp1 = Impact_Morninglight.new(:MANA_AMP, 10, self)
    imp2 = Impact_Morninglight.new(:MAX_LIFE_MULTI, 0.2, self)
    imps = [imp1, imp2]
    @impacting[member.id] = Buff_Eternal.new(self, member, imps, "Rise and Shine", ["Synergy"])
  end
  
  def remove_member(ex_member)
    super
    return unless @impacting.include?(ex_member.id)
    @impacting[ex_member.id].clear_buff
    @impacting.delete(ex_member.id)
  end

  def buff_visible?(buff)
    return false if level = 0
    return false if @owner.streak <= 0
    return true
  end
    
end
register_synergy(Synergy_Morninglight, :MORNINGLIGHT)