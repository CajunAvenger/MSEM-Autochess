# Aerial
# Innate
# Aerials can move through allies.
# @3/5/7
# Aerials take reduced melee damage from non-Aerials.
class Synergy_Aerial < Synergy
  def key
    return :AERIAL
  end
  
  def breakpoints
    return [3, 5, 7]
  end
  
  def has_innate?
    return true
  end
  
  def sprite
    return "Aerial"
  end
  
  def info_text(lv=level)
    return {
      :name => "Aerial",
      :breaks => breakpoints,
      :level => lv,
      :header => "Aerials can move over allies.",
      :blocks => [
        "Aerials take 15% reduced damage~" +
        "from non-Aerial attacks.",
        "30% reduced damage.",
        "45% reduced damage."
      ],
      :bm => "5",
      :members => @member_names
    }
  end
  
  def blanketer
    return true
  end
  
  def add_member(member, leech=false)
    super
    sweet_flip = Proc.new do |listen, damage_event|
      lv = listen.subscriber.level
      next unless lv > 0
      next unless damage_event.is_a?(Damage_Attack)
      next if damage_event.source.synergies.include(:AERIAL)
      next if damage_event.source.impacts.include(:HighSwing)
      val = (lv + listen.host.get_value(:BonusAirTime)).cap(6)
      reduce = [1, 0.85, 0.7, 0.55, 0.4, 0.25, 0.1]
      damage_event.set_to(listen.host, damage_event.amount*reduce)
    end
    l = gen_subscription_to(member, :IncomingDamage, sweet_flip)
    @member_listeners[member.id] = [l]
  end
  
  def apply(unit)
    return if @impacting.include?(unit.id)
    efs = []
    efs.push(Impact_SynCheck_Harsh.new(:Aerial, 1, :AERIAL, self))
    @impacting[unit.id] = Buff_Eternal.new(self, unit, efs, "Aerial")
  end
  
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    @impacting[unit.id].clear_buff
    @impacting.delete(unit.id)
  end
  
end
register_synergy(Synergy_Aerial, :AERIAL)