# An Impact applies some effect to its target
# Impacts are managed by AoEs, Artifacts, Auras, and Buffs
# The most basic Impact is just an id and a number
# :POWER => 10 to increase the target's power by 10
# An Impact by default also includes an add and a multi variable
# These are initialized as 0 and 1 respectively on a full equation of
# multi * (amount + add)
# This applies to the standard stats (:WARD, :MAX_LIFE, etc),
#  their multipliers (:MULTI_MULTI, :MANA_AMP_MULTI, etc), 
#  and other effects such as :LIFESTEAL (defining the percentage of damage gained)
# 
# Some Impacts are simply a boolean effect, eg :CLOAK and :TAUNT
# Giving these a negative value negates the existence of another
# 
# Other Impact keys can be made which have no inherent effect,
#  but instead are checked at various points (usually manager Listener calls)
#  for example :HEALING and :MANAGAIN, which Buffs use to apply heals over ticks
# 
# More complicated setups are possible via a subclass
# For example Impact_KeyPercent further takes a Unit and a Key
# Then multiplies the amount by Unit.get_value(Key)
# ie Impact_KeyPercent(:WARD, 0.5, Unit, :POWER)
# adds Ward to the target equal to half its Power
class Impact
  attr_reader :source           # what created this Impact?
  attr_accessor :target         # what is holding this Impact?
  attr_accessor :id             # what stat does this affect?
  attr_accessor :amount         # by how much?
  attr_accessor :add            # added bonus to that
  attr_accessor :dec            # subtract this from the final
  attr_accessor :multi          # multiplied bonus to both
  attr_accessor :super_multi    # multiplied bonus to all three
  attr_accessor :buffers        # what objects are buffing this Impact?
  attr_reader :loop_id          # id for loop protection
  attr_accessor :focus          # focus for effects like Taunting
  attr_accessor :link           # linked impact for Impact_Linked
  
  def initialize(id, amount, source=nil, focus=nil)
    @id = id
    @amount = amount
    @source = source
    @focus = focus
    @add = 0
    @multi = 1
    @super_multi = 1
    @dec = 0
    @buffers = []
    @loop_id = ("Impact" + get_impact_id.to_s).to_sym
  end
  
  def get_value
    #console.log(@super_multi)
    #console.log(get_multi)
    #console.log(@amount)
    #console.log(get_add)
    #console.log(@dec)
    return (@super_multi)*(get_multi()*(@amount+get_add())) - @dec
  end
  
  def get_multi
    return @multi
  end
  
  def get_add
    return @add
  end
  
  def register(source, target)
    @source = source
    @target = target
  end
  
  def enchant(buffer, add=0, super_multi=0)
    @buffers.push(buffer)
    @add += add
    @super_multi += super_multi
  end
  
  def disenchant(buffer, add=0, super_multi=0)
    @buffers.delete(buffer)
    @add -= add
    @super_multi -= super_multi
  end
  
  def expire
    if @source.is_a?(Buff)
      @source.clear_buff
    elsif @source.is_a?(AoE)
      @source.clear_aoe
    end
  end

  # its possible for impacts to scale off each other
  # in many cases that's fine, even if they loop as a whole
  #  as long as those impacts don't loop on an individual unit
  # ie A's power scaling on B's ward that scale's on C's power is fine
  #  but not if C is A
  # ideally we design around these loops being possible in the first place
  # but this acts as a emergency backup
  def loop_check
    return 0 unless $loop_check[:active]
    if $loop_check.include?(@loop_id)
      $loop_check[@loop_id] += 1
    else
      $loop_check[@loop_id] = 1
    end
    return $loop_check[@loop_id]
  end
  
  def clone_args(new_target)
    return [
      self.class,
      [@id, @amount, @source],
      [
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
  
  def create_clone(new_target)
    args = clone_args(new_target)
    i = args[0].new(*args[1])
    for a in args[2]
      i.instance_variable_set("@"+a[0], a[1])
    end
    return i
  end
  
end
$loop_check = {:active => false}