# an Impact that scales off a base stat of the target
class Impact_SelfPercent < Impact
  attr_accessor :key            # the stat this is scaling off of   
  
  def initialize(id, scale, key)
    super(id, scale)
    @key = key
  end
  
  def get_multi
    return 1 unless @target
    return @target.get_base(key)
  end
  
  def clone_args(new_target)
    return [
      Impact_SelfPercent,
      [@id, @amount, @key],
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