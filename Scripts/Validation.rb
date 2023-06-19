# The Kernel module is extended to include the validate method.
module Kernel
  private
  
  # Used to check whether method arguments are of a given class
  #    or respond to a method.
  # @param value_pairs [Hash{Object => Class, Array<Class>, Symbol}]
  #    value pairs to validate
  # @example Validate a class or method
  #   validate foo => Integer, baz => :to_s
  #   raises an error if foo is not an Integer or if baz doesn't implement #to_s
  # @example Validate a class from an array
  #   validate foo => [Artifact, Aura]
  #   raises an error if foo isn't an Artifact or Aura
  # @raise [ArgumentError] if validation fails
  def validate(value_pairs)
    unless value_pairs.is_a?(Hash)
      raise ArgumentError, "Non-hash argument #{value_pairs.inspect} passed into validate."
    end
    errors = value_pairs.map do |value, condition|
      if condition.is_a?(Array)
        unless condition.any? { |klass| value.is_a?(klass) }
          next "Expected #{value.inspect} to be one of #{condition.inspect}, but got #{value.class.name}."
        end
      elsif condition.is_a?(Symbol)
        next "Expected #{value.inspect} to respond to #{condition}." unless value.respond_to?(condition)
      elsif !value.is_a?(condition)
        next "Expected #{value.inspect} to be a #{condition.name}, but got #{value.class.name}."
      end
    end
    errors.compact!
    return if errors.empty?
    raise ArgumentError, "Invalid argument passed to method.\r\n" + errors.join("\r\n")
  end
end

class Numeric
  
  def cap(val)
    return val if self > val
    return self
  end
  
  def low_cap(val)
    return val if self < val
    return self
  end
  
end

class Array
  
  def shuffle
    len = self.length-1
    ind_ar = *(0..len)
    out_ar = []
    for i in 1..len
      r_ind = ind_ar[rand(ind_ar.length)]
      out_ar.push(self[r_ind])
      ind_ar.delete_at(r_ind)
    end
    return out_ar
  end
  
  def sum
    val = 0
    for e in self
      next unless e.is_a?(Numeric)
      val += e
    end
    return val
  end
  
  def sample
    return self[rand(self.length)]
  end
  
end