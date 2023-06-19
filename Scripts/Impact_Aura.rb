# Impact that scales off the number of Auras the target's owner has
class Impact_Aura < Impact
  def get_multi
    return 0 unless @target
    return @target.owner.auras.length
  end
end

# Impact that applies if a unit has a Synergy and its owner has a particular Aura
class Impact_AuraSynScale < Impact
  def initialize(id, amount, host_syn, aura, exc=false)
    super(id, amount)
    @host_syn = host_syn
    @aura = aura
    @exc = exc
    @aura_confirmed = false
  end
  
  def get_multi
    return 0 unless @target
    return 0 if @exc && !@target.synergies.include?(@host_syn.key)
    unless @aura_confirmed
      @aura_confirmed = @target.owner.has_aura?(@aura)
      return 0 unless @aura_confirmed
    end
    return @host_syn.level
  end
  
  def clone_args(new_target)
    return [
      Impact_AuraSynScale,
      [@id, @amount, @host_syn, @aura, @exc],
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