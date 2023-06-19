# an Impact that scales off a particular Unit's value
class Impact_KeyPercent < Impact
  attr_accessor :key            # the stat this is scaling off of   
  attr_accessor :scalar         # the unit this is scaling off of
  
  def initialize(id, scale, scalar, key)
    super(id, scale)
    @scalar = scalar
    @key = key
  end
  
  def get_multi
    lc = loop_check()
    return 0 if lc > 1
    return @scalar.get_base(key) if lc > 0
    return @scalar.get_value(key)
  end
  
  def clone_args(new_target)
    return [
      Impact_KeyPercent,
      [@id, @amount, @scalar, @key],
      [
        ["source", @source],
        ["target", new_target],
        ["add", @add],
        ["dec", @dec],
        ["multi", @multi],
        ["super_multi", @super_multi],
        ["buffers", @buffers],
        ["focus", @focus],
        ["link", @link]
      ]
    ]
  end
end