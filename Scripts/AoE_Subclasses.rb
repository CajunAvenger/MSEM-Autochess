# Shortcut for an AoE that applies to all units created by the creator
class AoE_Boon < AoE
  def initialize(hash)
    return AoE_Boon_Timed.new(hash) if hash[:duration]
    super
  end
  
  def applies_to?(target)
    return target.owner == @source.owner
  end

end

class AoE_Boon_Eternal < AoE_Boon
  include Eternal
end

# Shortcut for an AoE that applies to all units not created by the creator
class AoE_Curse < AoE
  def initialize(hash)
    return AoE_Curse_Timed.new(hash) if hash[:duration]
    super
  end
  
  def applies_to?(target)
    return target.owner != @source.owner
  end
  
end

class AoE_Curse_Eternal < AoE_Curse
  include Eternal
end

class AoE_Syn_Boon < AoE_Boon_Eternal
  def applies_to?(target)
    return false unless target.owner == @source.owner
    share = target.synergies & @source.synergies
    return share.length > 0
  end

end