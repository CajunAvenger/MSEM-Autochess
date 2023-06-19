# Shaharazad
# @2
# The first time each of your planeswalkers would drop to 0 life,
#  instead they drop to 1 life and briefly become invulnerable.

class Synergy_Shaharazad < Synergy
  
  def deployer
    return true
  end
  
  def sprite
    return "Shaharazad"
  end
  
  def key
    return :SHAHARAZAD
  end
  
  def breakpoints
    return [2]
  end
  
  def info_text(lv=level)
    return {
      :name => "Shaharazad",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "The first time each of your~" +
        "planeswalkers die, instead they~" +
        "become briefly invulnerable at 1 life."
      ],
      :bm => 3,
      :members => @member_names
    }
  end
  
  def match_apply(m, lv=level)
    return unless lv > 0
    return unless m.is_a?(Planeswalker)
    death_save = Proc.new do |listen, damage_event|
      console.log("death save")
      dead_man = listen.host
      dead_man.current_damage = dead_man.get_value(:MAX_LIFE) - 1
      gen_invulnerable_buff(self, dead_man, 2, "Deus ex Machina")
    end
    l = gen_subscription_to(m, :Dying, death_save)
    l.fragile = true
    @match_listeners.push(l)
  end
  
  def init_match_listeners
    lv = level
    return unless lv > 0
    for m in @owner.deployed do
      match_apply(m, lv)
    end
  end
  
end
register_synergy(Synergy_Shaharazad, :SHAHARAZAD)