# special Impacts that really only exist for a single thing

# Increase stat by Commander Synergy Soldiers
class Impact_Commander < Impact_SynScale
  def get_multi
    return 0 unless @target
    counter = 0
    for u in @target.owner.deployed
      counter += 1 if u.is_a?(Commander_Soldier)
    end
    return counter
  end
end

# Increase stat depending on gold reserves
class Impact_Draconic < Impact
  def initialize(id, amount, host_syn)
    super(id, amount)
    @host_syn = host_syn
  end
  
  def get_multi
    return 0 if @host_syn.level < 1
    return @host_syn.owner.gold.to_f / 100
  end
  
  def clone_args(new_target)
    return [
      Impact_Draconic,
      [@id, @amount, @host_syn],
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

# Increase stat depending on gold reserves
class Impact_Hoard < Impact
  def get_multi
    return @target.owner.gold.to_f / 100
  end

end


# Impact for Elder synergy
class Impact_ElderPercent < Impact
  attr_accessor :key
  attr_accessor :syn_min
  attr_accessor :host_syn
  
  def initialize(id, scale, key, syn_min, syn)
    super(id, scale)
    @key = key
    @host_syn = syn
    @syn_min = syn_min
  end
  
  def get_multi
    return 0 if @host_syn.level < @syn_min
    return 1 unless @target
    return @target.get_base(@key)
  end
  
  def clone_args(new_target)
    return [
      Impact_ElderPercent,
      [@id, @amount, @key, @syn_min, @host_syn],
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

# Impact that increases Morninglight stats based on winrate
class Impact_Morninglight < Impact_SynScale
  def initialize(id, amount, host_syn)
    @host_syn = host_syn
    super
  end
  
  def get_multi
    return 0 if @host_syn.level == 0
    return 0 if @host_syn.owner.streak <= 0
    return 0 unless @target.synergies.include?(:MORNINGLIGHT)
    return @host_syn.owner.streak
  end
end

# Impact for range scaling
class Impact_Scout < Impact_SynScale
  def get_multi
    return 0 if !@target.synergies.include?(:SCOUT)
    return 0 if !@target.current_hex
    lv = @host_syn.level()
    return 0 if lv < 1
    return 1 if !@target.aggro
    r = @target.current_hex.get_range_distance_to(@target.aggro.current_hex)
    return lv if r[0] == nil
    return lv * r[0]
  end
end

# Increase stat if Sisters synergy includes Flynn
class Impact_FlynnSisterhood < Impact_SynScale
  def get_multi
    if @host_syn.member_names.include?("Flynn")
      return 1
    else
      return 0
    end
  end
end

# Incrase stat for each Artificer with a completed item you have
class Impact_Spectacle < Impact
  def get_multi
    return 0 unless @target
    counter = 0
    for id, u in @target.owner.units
      next if u.is_benched?
      next unless u.synergies.include?(:ARTIFICER)
      for a in u.artifacts
        next unless a.is_completed
        counter += 1
        break
      end
    end
    return counter
  end
end

# Increase stats for shop refreshes
class Impact_Refresh < Impact
  def initialize(id, amount, check=nil)
    @check = check
    super(id, amount)
  end
  
  def get_multi
    return 0 unless @target
    if @check
      return 1 if @target.owner.refresh_counter >= @check
      return 0
    else
      return @target.owner.refresh_counter
    end
  end
  
  def clone_args(new_target)
    return [
      Impact_Refresh,
      [@id, @amount, @check],
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