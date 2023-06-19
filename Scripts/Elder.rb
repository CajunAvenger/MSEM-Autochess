# Elder
# @2
# Shop fills as if 1 level higher after wins.
# @5
# Your planeswalkers gain ward and toughness proportional to their base cost.
# @8
# Also power and mana amp.
class Synergy_Elder < Synergy
  
  def key
    return :ELDER
  end
  
  def breakpoints
    return [2, 5, 8]
  end
  
  def sprite
    return "Elder"
  end
  
  def initialize(owner)
    super
    bumper = Proc.new do |listen, streak|
      next unless listen.subscriber.level > 0
      next unless listen.host.storefront
      listen.host.storefront.next_bumper += 1
    end
    gen_subscription_to(owner, :RoundWon, bumper)
  end

  def info_text(lv=level)
    return {
      :name => "Elder",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "After winning, your shop fills as~" +
        "though you were 1 level higher.",
        "Your planeswalkers gain ward~" +
        "and toughness based on their cost.",
        "Your planeswalkers gain power~" +
        "and mana amp based on their cost.",
      ],
      :multiblock => {2 => [1], 3 => [1, 2]},
      :members => @member_names
    }
  end

  def blanketer
    return true
  end
  
  def apply(unit)
    return if @impacting.include?(unit.id)
    imps = [
        Impact_ElderPercent.new(:WARD, 20, :COST, 2, self),
        Impact_ElderPercent.new(:TOUGHNESS, 20, :COST, 2, self),
        Impact_ElderPercent.new(:POWER, 20, :COST, 3, self),
        Impact_ElderPercent.new(:MANA_AMP, 20, :COST, 3, self)
    ]
    @impacting[unit.id] = Buff_Eternal.new(self, unit, imps, "Elder's Wisdom")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end

end
register_synergy(Synergy_Elder, :ELDER)