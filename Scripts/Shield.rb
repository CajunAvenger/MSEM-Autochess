# shortcut for Shield impact
class Shield < Impact
  attr_accessor :classes
  attr_accessor :skeys
  
  def initialize(amount, classes=nil, skeys=nil)
    @classes = classes
    @skeys = skeys
    super(:SHIELD, amount)
  end
  
  def check_shield(amount, damage_event)
    valid = true
    valid = false if @classes || @skeys
    if @classes
      for c in @classes
        valid = true if damage_event.is_a?(c)
        valid = true if damage_event.source.is_a?(c)
      end
    end
    if !valid && @skeys
      for k in @skeys
        valid = true if damage_event.keys.include?(k)
      end
    end
    return amount unless valid
    rem = get_value
    if rem > amount
      # prevent it all and stay up
      @dec += amount
      return 0
    else
      amount -= rem
      expire
      return amount
    end
  end
  
  def clone_args(new_target)
    return [
      Shield,
      [@amount, @classes, @skeys],
      [
        ["source", @source],
        ["target", new_target],
        ["add", @add],
        ["dec", @dec],
        ["multi", @multi],
        ["super_multi", @super_multi],
        ["buffers", @buffers],
        ["focus", @focus],
        ["link", @link],
      ]
    ]
  end
end
# Shield that protects against N instances of damage instead of N amount of damage
class Shield_Stocked < Shield
  def initialize(stocks, classes=nil, keys=nil)
    @stocks = stocks
    super(1000*stocks, classes, keys)
  end
  
  def check_shield(amount, damage_event)
    valid = true
    valid = false if @classes || @skeys
    if @classes
      for c in @classes
        valid = true if damage_event.is_a?(c)
        valid = true if damage_event.source.is_a?(c)
      end
    end
    if !valid && @skeys
      for k in @skeys
        valid = true if damage_event.keys.include?(k)
      end
    end
    return amount unless valid
    @stocks -= 1
    @amount -= 1000
    expire if @stocks == 0
    return 0
  end
  
  def clone_args(new_target)
    return [
      Shield_Stocked,
      [@stocks, @classes, @skeys],
      [
        ["source", @source],
        ["target", new_target],
        ["add", @add],
        ["dec", @dec],
        ["multi", @multi],
        ["super_multi", @super_multi],
        ["buffers", @buffers],
        ["focus", @focus],
        ["link", @link],
      ]
    ]
  end
  
end