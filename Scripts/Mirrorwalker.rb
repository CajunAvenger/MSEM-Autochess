# Mirrorwalkers
# @2/3/4/5
# Your Mirrorwalkers have an increasing chance to teleport a short distance
#  when targeted by a spell.

class Synergy_Mirrorwalker < Synergy
  
  def key
    return :MIRRORWALKER
  end
  
  def breakpoints
    return [2, 3, 4, 5]
  end
  
  def sprite
    return "Mirrorwalker"
  end
  
  def info_text(lv=level)
    return {
      :name => "Mirrorwalker",
      :breaks => breakpoints,
      :level => lv,
      :header => "Mirrorwalkers have chance to~" +
        "teleport when targeted by a spell.",
      :blocks => [
        "20% chance to teleport.",
        "40% chance to teleport.",
        "60% chance to teleport.",
        "80% chance to teleport."
      ],
      :members => @member_names
    }
  end
  
  def add_member(member, leech=false)
    super
    # add teleport listener
    juke = Proc.new do |listen, targeter, target_info|
      lv = listen.subscriber.level()
      next if lv < 1
      next unless rand(100) < 20 * lv
      range = 1
      range = 2 if lv = 4
      ar = listen.host.current_hex.get_area_hexes(range)[0] - target_info[0]
      moved = nil
      for h in ar
        moved = h.set_battler(listen.host)
        break if moved
      end
    end
    l = gen_subscription_to(member, :BeingTargeted, juke)
    @member_listeners[member.id] = [l]
  end
end
register_synergy(Synergy_Mirrorwalker, :MIRRORWALKER)