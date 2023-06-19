# Artificer
# @2/4/6
# Increasing chance to gain item components after winning fights.
# @6
# Chance to gain completed items, too.
class Synergy_Artificer < Synergy
  
  def key
    return :ARTIFICER
  end
  
  def breakpoints
    return [2, 4, 6]
  end
  
  def sprite
    return "Artificer"
  end  
  
  def info_text(lv=level)
    return {
      :name => "Artificer",
      :breaks => breakpoints,
      :level => lv,
      :header => "Chance to gain components after~" +
        "winning combats.",
      :blocks => [
        "10% chance for component.",
        "20% chance for component.",
        "30% chance for component. Also~" +
        "10% chance for complete artifacts."
      ],
      :members => @member_names
    }
  end
  
  def initialize(owner)
    super
    free_stuff = Proc.new do |listen, streak|
      lv = listen.subscriber.level
      comp_c = [0, 10, 20, 30][lv]
      cmpl_c = [0, 0, 0, 10][lv]
      r1 = rand(100)
      r1 = 0
      if r1 < comp_c
        @owner.give_artifact($artifacts[:component].sample.new)
      end
      r2 = rand(100)
      if r2 < cmpl_c
        @owner.give_artifact($artifacts[:complete].sample.new)
      end
    end
    gen_subscription_to(owner, :RoundWon, free_stuff)
  end
  
end
register_synergy(Synergy_Artificer, :ARTIFICER)