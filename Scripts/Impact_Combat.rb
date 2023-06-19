# multiply Impact value by % finished combat is
class Impact_Combat < Impact
  def get_multi
    return 0 unless @target
    return @target.owner.match.combat_frames / @target.owner.match.max_combat_frames
  end
end

# multiply Impact value by inverse % finished combat is
class Impact_UnCombat < Impact
  def get_multi
    return 0 unless @target
    return 1 - (@target.owner.match.combat_frames / @target.owner.match.max_combat_frames)
  end
end

# Impact that's only active while being targetted
class Impact_Sight < Impact
  def get_multi
    return 0 unless @target
    return 0 unless $processor_status == :combat_phase
    for u in @target.owner.opponent.deployed
      return 1 if u.aggro == @target
    end
    return 0
  end
end

# multiply Impact value by number of opponents targetting the target
class Impact_Sights < Impact
  def get_multi
    return 0 unless @target
    return 0 unless $processor_status == :combat_phase
    count = 0
    for u in @target.owner.opponent.deployed
      count += 1 if u.aggro == @target
    end
    return count
  end
end

# multiply Impact value by % charged the target's spell is
class Impact_Mana < Impact
  def get_multi
    return 0 unless @target
    return (@target.mana / @target.ability_cost).cap(1)
  end
end

# multiply Impact value by 1-% charged the target's spell is
class Impact_Unmana < Impact
  def get_multi
    return 0 unless @target
    return 1 - (@target.mana / @target.ability_cost).cap(1)
  end
end

# Impact that applies when under a certain life value
class Impact_UnderLife < Impact
  def initialize(id, amount, check, source=nil, target=nil)
    super(id, amount, source, target)
    @check = check
  end
  
  def get_multi
    return 0 unless @target
    l = @target.get_life
    if @check < 1
      # percentage
      ml = @target.get_value(:MAX_LIFE)
      return 1 if l/ml < @check
    else
      return 1 if l < @check
    end
    return 0
  end
  
  def clone_args(new_target)
    return [
      Impact_UnderLife,
      [@id, @amount, @check, @source, new_target],
      [
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

# Impact that scales with the number of units of a synergy you have deployed
class Impact_DeployedSyn < Impact
  
  def initialize(id, amount, dkey)
    @dkey = dkey
    super(id, amount)
  end
  
  def get_multi
    return 0 unless @target
    counter = 0
    for id, u in @target.owner.units
      if $processor_status == :combat_phase
        counter += 1 if u.synergies.include?(@dkey) && u.deployed
      else
        counter += 1 if u.synergies.include?(@dkey) && !u.is_benched?
      end
    end
    return counter
  end
  
  def clone_args(new_target)
    return [
      Impact_DeployedSyn,
      [@id, @amount, @dkey],
      [
        ["add", @add],
        ["target", @target],
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

# Impact that's active if you've deployed a particular kind of unit
class Impact_DeployedFriend < Impact
  
  def initialize(id, amount, fname)
    @fname = fname
    super(id, amount)
  end
  
  def get_multi
    return 0 unless @target
    for id, u in @target.owner.units
      next unless u.name == @fname
      if $processor_status == :combat_phase
        return 1 if u.deployed
      else
        return 1 if !u.is_benched?
      end
    end
    return 0
  end
  
  def clone_args(new_target)
    return [
      Impact_DeployedFriend,
      [@id, @amount, @fname],
      [
        ["add", @add],
        ["target", @target],
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