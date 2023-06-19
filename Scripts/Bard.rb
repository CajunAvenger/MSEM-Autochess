# Bard
# @2
# Whenever one of your Bards casts their spell,
#  charge 10% of each other planeswalker's spell.
# @4
# Charge 20%.
class Synergy_Bard < Synergy

  def key
    return :BARD
  end
  
  def breakpoints
    return [2, 4]
  end
  
  def sprite
    return "Bard"
  end

  def info_text(lv=level)
    return {
      :name => "Bard",
      :breaks => breakpoints,
      :level => lv,
      :header => "Your planeswalkers charge~" +
      "their spell when your Bards cast.",
      :blocks => [
        "10% of mana cost.",
        "20% of mana cost."
      ],
      :bm => 4,
      :members => @member_names
    }
  end
  
  def add_member(member, leech=false)
    super
    inspiring_song = Proc.new do |listen, target_info, iter|
      lv = listen.subscriber.level
      for u in listen.host.owner.deployed
        next if u == listen.host
        next unless u.is_a?(Planeswalker)
        cost = u.ability_cost * lv / 10
        u.apply_mana_heal(Impact.new(:MANAGAIN, cost))
      end
    end
    blisten = gen_subscription_to(member, :UsedAbility, inspiring_song)
    @member_listeners[member.id] = [blisten]
  end
  
end
register_synergy(Synergy_Bard, :BARD)
