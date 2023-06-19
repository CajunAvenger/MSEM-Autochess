module Timed
  attr_accessor :duration
  
  def init_timer(sym)
    duration_script = Proc.new do |listen, *args|
      listen.subscriber.duration -= 1
      listen.subscriber.trigger_effect()
      listen.subscriber.clear_buff() if listen.subscriber && listen.subscriber.duration <= 0
    end
    gen_subscription_to(@source.owner.match, sym, duration_script)
  end
    
end

module Eternal
   # Buffs and AoEs are cleared at end of round unless it is_a?(Eternal)
 end
 
module Total_AoE
  # An AoE that covers the entire GameBoard
end
