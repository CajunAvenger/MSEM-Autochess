class Listener
  attr_reader :host             # object this is listening to
  attr_reader :subscriber       # object that created this listener
  attr_reader :key              # symbol this reacts to
  attr_reader :call_func        # function called when symbol emitted
  attr_reader :id               # listenerid
  attr_reader :id_number        # id number
  attr_accessor :fragile        # destroy after emitting?
  
  def initialize (host, subscriber, key, call_func)
    @host = host
    @subscriber = subscriber
    @key = key
    @call_func = call_func
    @id_number = get_listener_id()
    @id = "Listener"+@id_number.to_s
    console.log(@id)
    host.register_listener(self)
    subscriber.cache_listener(self)
  end
  
  def clear_listener
    @host.clear_listener(self) if @host
    @subscriber.drop_listener(self) if @subscriber
    @host = nil
    @subscriber = nil
  end
  
  def called (*args)
    # Proc gets original emit arguments but with listener instead of sym
    # if it needs sym, it can get it with listener.key
    # use listen.subscriber.[var] instead of @var in the Proc to be updated
    call_func.call(self, *args)
    clear_listener() if @fragile
  end
  
end

class Emitter
  attr_accessor :listening_to_me    # object of listeners listening to this
  attr_accessor :my_listener_cache  # array of listeners this has out
  # listening_to_me = {:Died => [ListenerFromAoE, ListenerFromBuff]}
  # my_listener_cache = [ListenerToToken, ListenerToArtifact]
  
  def gen_subscription_to(host, key, call_func)
    return Listener.new(host, self, key, call_func)
  end
  
  def gen_subscription_for(subscriber, key, &call_func)
    return Listener.new(self, subscriber, key, &call_func)
  end
  
  # subscriber initializes a listener
  # this registers it to this host's listener map
  def register_listener(listen)
    if @listening_to_me == nil
      @listening_to_me = {listen.key => [listen]}
    elsif !@listening_to_me.include?(listen.key)
      @listening_to_me[listen.key] = [listen]
    else
      @listening_to_me[listen.key].push(listen)
    end
  end
  # and saves it to their own listener array
  
  def cache_listener(listen)
    @my_listener_cache.push(listen) unless @my_listener_cache.include?(listen)
  end
  
  # remove listener from host
  def clear_listener(listen)
    @listening_to_me[listen.key].delete(listen)
  end
  # remove listener from subscriber
  def drop_listener(listen)
    @my_listener_cache.delete(listen)
  end
  
  def clear_listeners
    for l in @my_listener_cache
      l.clear_listener()
    end
  end
  
  def silence_listeners
    for id, ls in @listening_to_me
      for l in ls
        l.clear_listener
      end
    end
  end
  
  def emit(key, *args)
    if @listening_to_me.include?(key)
      #console.log(self.id.to_s + " emitted " + key.to_s + " to " + @listening_to_me[key].length.to_s + " listeners.")
      for listen in @listening_to_me[key]
        #console.log(listen.subscriber.id)
        listen.called(*args)
      end
    end
    # also make the game emit the event
    if self.is_a?(Enchantable)
      self.owner.emit(key, self, *args)
    end
    if $match && !self.is_a?(Match)
      #console.log("match mirroring " + key.to_s + " from " + self.id.to_s)
      $match.emit(key, self, *args)
    end
  end
  
  def local_emit(key, *args)
    if @listening_to_me.include?(key)
      #console.log(self.id.to_s + " emitted " + key.to_s + " to " + @listening_to_me[key].length.to_s + " listeners.")
      for listen in @listening_to_me[key]
        #console.log(listen.subscriber.id)
        listen.called(*args)
      end
    end
  end
  
end