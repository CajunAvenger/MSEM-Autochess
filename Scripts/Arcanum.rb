# Arcanum
# 2/4/6: Your planeswalkers gain power and toughness
#  after a higher-cost planeswalker casts a spell.
class Synergy_Arcanum < Synergy
  attr_accessor :marks
  
  def initialize(owner)
    @marks = []
    super
  end
  
  def key
    return :ARCANUM
  end
  
  def breakpoints
    return [2, 4, 6]
  end
  
  def sprite
    return "Arcanum"
  end
  
  def info_text(lv=level)
    return {
      :name => "Arcanum",
      :breaks => breakpoints,
      :level => lv,
      :header => "Your planeswalkers gain power and~" + 
        "toughness when your higher cost~planeswalkers cast spells.",
      :blocks => [
        "+10 power and toughness.",
        "+20 power and toughness.",
        "+30 power and toughness."
      ],
      :members => @member_names
    }
  end
  
  def deployer
    return true
  end
  
  def mentor
    return Proc.new do |listen, target_info, iter|
      cost = listen.host.cost
      for b in listen.subscriber.marks
        next unless b.target.cost < cost
        next unless b.target.is_a?(Planeswalker)
        for i in b.impacts
          i.amount += (10 * level())
        end
      end
    end
  end
  
  def init_match_listeners
    @marks = []
    mproc = mentor
    for u in @owner.deployed
      match_apply(u, mproc)
      l = gen_subscription_to(u, :UsedAbility, mproc)
      @match_listeners.push(l)
    end
  end
  
  def match_apply(u, mproc=mentor)
    return unless level > 0
    efs = [
      Impact.new(:POWER, 0),
      Impact.new(:TOUGHNESS, 0)
    ]
    @marks.push(Buff.new(self, u, efs, "High Marks"))
    return if u.cost == 1
  end

end
register_synergy(Synergy_Arcanum, :ARCANUM)