# A buff applied to a unit
class Buff < Emitter
  attr_reader :name             # name of this Buff
  attr_reader :id_number        # id#
  attr_reader :id               # id Buff#
  attr_accessor :target         # the Unit this Buff is on
  attr_accessor :source         # the Emitter this Buff is from
  attr_accessor :impacts        # the array of Impacts this gives
  attr_accessor :keys           # other keys
  attr_accessor :neutralized    # allow other effects to shut this off
  attr_accessor :game           # the gameboard, for duration
  attr_accessor :counter        # counter for listeners to edit
  attr_accessor :board_sprite   # sprite on the board because of this buff
  attr_accessor :icon           # infobox sprite for this buff
  SELF_DATA = { :name => "Buff" }
    
  # initialize the buff/debuff
  def initialize(source, target, effects, name=SELF_DATA[:name], keys=nil)
    # init basic attrs
    @listening_to_me = {}
    @my_listener_cache = []
    @source = source
    @target = target
    @name = name
    @keys = keys
    @neutralized = false
    @id_number = get_buff_id()
    @id = @name + @id_number.to_s
    # set array of Impacts and register
    @impacts = effects
    @impacts = [effects] if effects.is_a?(Impact)
    if @impacts
      for ef in @impacts do
        ef.register(self, @target)
      end
    else
      @impacts = []
    end
    # apply buff modifiers
    @source.emit(:Buffing, self)
    if @target
      @target.emit(:BeingBuffing, self)
      # quit if that ends up killing the buff
      return if @neutralized
      # otherwise apply the buff
      apply(@target)
    end
  end
    
  def get_description
    return "Someone forgot to give this buff a description."
  end
  
  # run the actual script, super'd in subclasses
  def trigger_effect(target=@target)
    for imp in impacts
      if imp.id == :HEALING
        @target.apply_heal(imp)
      end
      if imp.id == :MANA_GAIN
        @target.apply_mana_heal(imp)
      end
    end
  end
  
  def expire_effect
    emit(:Expired)
  end
    
  def visible
    if source.is_a?(Synergy)
      return source.buff_visible?(buff)
    else
      return true
    end
  end
  
  def apply(target)
    target.add_buff(self)
    stun = false
    cloak = false
    flicker = false
    for imp in @impacts
      target.add_impact(imp)
      stun = true if imp.id == :STUN
      cloak = true if imp.id == :CLOAK
      flicker = true if imp.id == :FLICKER
    end
    target.stun if stun && !(cloak || flicker)
  end
  
  def unapply(target)
    return unless target
    target.remove_buff(self)
    for imp in @impacts
      target.remove_impact(imp)
    end
  end
  
  def clear_buff
    expire_effect()
    unapply(@target)
    @board_sprite.dispose if @board_sprite
    clear_listeners()
  end
  
  def clone_args(new_target, new_efs)
    return [
      Buff,
      [@source, new_target, new_efs, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end
  
  def create_clone(new_target)
    new_efs = []
    for i in @impacts
      new_efs.push(i.create_clone(new_target))
    end
    args = clone_args(new_target, new_efs)
    b = args[0].new(*args[1])
    for a in args[2]
      b.instance_variable_set("@"+a[0], a[1])
    end
    return b
  end
  
end
