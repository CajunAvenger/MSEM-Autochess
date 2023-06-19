# Chronomancer
# @2/4/6/8
# Stunned enemies bleed [2/4/8/15]% of their maximum HP in true damage each second.
class Synergy_Chronomancer < Synergy
  def key
    return :CHRONOMANCER
  end
  
  def breakpoints
    return [2, 4, 6, 8]
  end
  
  def sprite
    return "Chronomancer"
  end
  
  def info_text(lv=level)
    return {
      :name => "Chronomancer",
      :breaks => breakpoints,
      :level => lv,
      :header => "Stunned enemies take damage~" + 
        "over time.",
      :blocks => [
        "Bleed 2% of max hp.",
        "Bleed 4% of max hp.",
        "Bleed 8% of max hp.",
        "Bleed 15% of max hp."
      ],
      :bm => "6",
      :members => @member_names
    }
  end
  
  def deployer
    return true
  end
  
  def punch_the_clock(lv=level)
    return Proc.new do |listen, buff|
      stunner = false
      for i in buff.impacts
        stunner = true if i.id == :STUN
      end
      next unless stunner
      ml = buff.source.get_value(:MAX_LIFE)
      per = [0, 0.02, 0.04, 0.08, 0.15][lv]
      DoT.new(listen.host, buff.target, per*ml*buff.duration, buff.duration)
    end
  end
  
  def match_apply(member, lv=level, pproc=punch_the_clock)
    return unless lv > 0
    l = gen_subscription_to(member, :Buffing, pproc)
    @match_listeners.push(l)
  end
    
  def init_match_listeners
    lv = level
    pproc = punch_the_clock(lv)
    for member in @members
      match_apply(member, lv, pproc)
    end
  end
=begin
    for member in @members
      punch_the_clock = Proc.new do |listen, buff|
        stunner = false
        for i in buff.impacts
          stunner = true if i.id == :STUN
        end
        next unless stunner
        imp = Impact.new(:ChronoStun, 1)
        imp.register(buff, buff.target)
        buff.impacts.push(imp)
      end
      l = gen_subscription_to(member, :Buffing, punch_the_clock)
      @match_listeners.push(l)
    end
    bleed = Proc.new do |listen, frames|
      p1 = listen.host.player1
      p2 = listen.host.player2
      opp = (p1 == @owner ? p2 : p1)
      for u in opp.deployed
        if u.impacts.include?(:ChronoStun)
          ml = u.get_value(:MAX_LIFE)
          src = u.impacts[:ChronoStun][0].source.source
          d = Damage.new(src, u, 0, per*ml).resolve()
        end
      end
    end
    l2 = gen_subscription_to(@owner.match, :Quarter, bleed)
    @match_listeners.push(l2)
=end
  
end
register_synergy(Synergy_Chronomancer, :CHRONOMANCER)