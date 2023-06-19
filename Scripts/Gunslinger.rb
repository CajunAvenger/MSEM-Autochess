# Gunslinger
# @2/4/6
# Every six attacks, your Gunslingers deal substantially increased damage.
class Synergy_Gunslinger < Synergy
  attr_accessor :bullets
  
  def initialize(owner)
    @bullets = {}
    super
  end
  
  def key
    return :GUNSLINGER
  end
  
  def breakpoints
    return [2, 4, 6]
  end
  
  def sprite
    return "Gunslinger"
  end
  
  def info_text(lv=level)
    return {
      :name => "Gunslinger",
      :breaks => breakpoints,
      :level => lv,
      :header => "Every six attacks, your~" +
      "Gunslingers do extra damage.",
      :blocks => [
        "100% increased power.",
        "200% increased power.",
        "300% increased power."
      ],
      :bm => 5,
      :members => @member_names
    }
  end
  
  def deployer
    return true
  end
  
  def reload(bonus=level)
    r = Proc.new do |listen, attack_keys|
      listen.subscriber.bullets[listen.host.id] += 1
      if listen.subscriber.bullets[listen.host.id] == 6
        listen.subscriber.bullets[listen.host.id] = 0
        attack_keys[:extra_p] += (bonus*listen.host.get_value(:POWER))
        attack_keys[:six_shot] = true
      end
    end
    return r
  end
  
  def match_apply(u, lv=level, rproc=reload)
    return unless lv > 0
    @bullets[u.id] = 0
    l = gen_subscription_to(u, :Attacking, rproc)
    @match_listeners.push(l)
  end
  
  def init_match_listeners
    @bullets = {}
    lv = level
    return unless lv > 0
    rproc = reload(lv)
    for u in @members
      match_apply(u, lv, rproc)
    end
  end
  
end
register_synergy(Synergy_Gunslinger, :GUNSLINGER)