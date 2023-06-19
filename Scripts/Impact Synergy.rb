# Impacts that scale off Synergy information

# An Impact that scales off its Synergy's level
# Optionally can be restricted to units with a specific Synergy
# Synergies may subclass this to scale off other things simply
class Impact_SynScale < Impact
  def initialize (id, amount, host_syn, syn_sym=nil)
    super(id, amount)
    @host_syn = host_syn
    @syn_sym = syn_sym
  end
  
  def get_multi
    if @syn_sym && !@target.synergies.include?(@syn_sym)
      return 0
    end
    return @host_syn.level()
  end
  
  def clone_args(new_target)
    return [
      Impact_SynScale,
      [@id, @amount, @host_syn, @syn_sym],
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

# An Impact that only applies if its Synergy is at a minimum level
class Impact_SynLimit < Impact
  def initialize (id, amount, host_syn, level)
    super(id, amount)
    @host_syn = host_syn
    @level = level
  end
  
  def get_multi
    return 0 unless @host_syn.level >= @level
    return @multi
  end
  
  def clone_args(new_target)
    return [
      Impact_SynLimit,
      [@id, @amount, @host_syn, @level],
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

# An Impact that only applies if the Unit has a particular Synergy
class Impact_SynCheck < Impact  
  def initialize (id, amount, syn_sym)
    super(id, amount)
    @syn_sym = syn_sym
  end
  
  def get_multi
    return 0 if !@target.synergies.include?(@syn_sym)
    return 1
  end
  
  def clone_args(new_target)
    return [
      Impact_SynCheck,
      [@id, @amount, @syn_sym],
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

# An Impact that only applies if the Unit has a particular Synergy
# And makes sure the Synergy has non-leeching members
class Impact_SynCheck_Harsh < Impact  
  def initialize (id, amount, syn_sym, host_syn)
    super(id, amount)
    @syn_sym = syn_sym
    @host_syn = host_syn
  end
  
  def get_multi
    return 0 if !@target.synergies.include?(@syn_sym)
    return 0 if @host_syn.member_names.length == 0
    return 1
  end
  
  def clone_args(new_target)
    return [
      Impact_SynCheck_Harsh,
      [@id, @amount, @syn_sym, @host_syn],
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
# Impact that scales off the owner's active synergies
# Can discount synergies, scale off a Synergy's level, or need a min level
class Impact_SynCounter < Impact
  def initialize(id, amount, skips=[], host_syn=nil, min_level=0, lv_scale=false)
    @skips = skips
    @host_syn = host_syn
    @min_level = min_level
    @lv_scale = lv_scale
    @mid = nil
    @cached_val = 0
    super(id, amount)
  end
  
  def get_multi
    return 0 unless @target
    return @cached_val if @mid == @target.owner.match.id && @cached_val
    multi = 1
    # check host synergy if we have one
    if @host_syn
      lv = @host_syn.level
      # not high enough level
      return 0 if lv < @min_level
      # scale by level
      multi = lv if @lv_scale
    end

    counter = 0
    for id, s in @target.owner.synergy_handlers
      next if @skips.include?(id)
      counter += 1 if s.level > 0
    end
    @mid = @target.owner.match.id if $processor_status == :combat_phase
    @cached_val = multi*counter
    return @cached_val
  end
  
  def clone_args(new_target)
    return [
      Impact_SynCheck,
      [@id, @amount, @skips, @host_syn, @min_level, @lv_scale],
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

