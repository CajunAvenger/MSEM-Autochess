# Impact that's only active while the target is moving towards a new attack target
class Impact_Moving < Impact
  def get_multi
    return 0 unless @target
    return 1 if @target.transit
    return 0
  end
end

# Impact that's only active while the target isn't moving towards a new attack target
class Impact_Standing < Impact
  def get_multi
    return 1 unless @target
    return 0 if @target.transit
    return 1
  end
end