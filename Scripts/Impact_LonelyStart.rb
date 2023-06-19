# Impact that's only active if no allies began combat around the target
class Impact_LonelyStart < Impact
  attr_accessor :cached_multi
  
  def get_multi
    return @cached_multi if $processor_status == :combat_phase && @cached_multi
    return 0 unless @target
    return 0 unless @target.current_hex
    if @target.current_hex.adjacent_allies == 0
      @cached_multi = 1
    else
      @cached_multi = 0
    end
    return @cached_multi
  end
  
end