# $timer is the instance of this class, reinitialized on match start
class Timer < Emitter
  def initialize(match)
    @listening_to_me = {}
    @my_listener_cache = []
    @match = match
    ticker = Proc.new do |listen, frames|
      listen.subscriber.tick_timers(frames)
    end
    framer = Proc.new do |listen, frames|
      listen.subscriber.frame_timers(frames)
    end
    gen_subscription_to(@match, :Tick, ticker)
    gen_subscription_to(@match, :Frame, framer)
    @id = 1
    @framers = {}
    @tickers = {}
  end
  
  def tick_timers(frames)
    for id, t in @tickers do
      t[:duration] -= 1
      if t[:duration] == 0
        if t[:ex]
          t[:proc].call(frames, t[:ex])
        else
          t[:proc].call(frames)
        end
        @tickers.delete(t)
      end
    end
  end
  
  def frame_timers(frames)
    for id, t in @framers do
      t[:duration] -= 1
      if t[:duration] == 0
        if t[:ex]
          t[:proc].call(frames, t[:ex])
        else
          t[:proc].call(frames)
        end
        @framers.delete(id)
      end
    end
  end
  
  def add_timer(hash, duration, proc, ex)
    hash[@id] = {
      :duration => duration,
      :proc => proc
    }
    hash[@id][:ex] = ex if ex
    @id += 1
  end
  
  def add_ticker(duration, proc, ex=nil)
    add_timer(@tickers, duration, proc, ex)
  end
  
  def add_framer(duration, proc, ex=nil)
    add_timer(@framers, duration, proc, ex)
  end
end