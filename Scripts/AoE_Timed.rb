class AoE_Timed < AoE
  attr_accessor :duration       # duration of this AoE
  
  include Timed
  
  def initialize(hash)
    @duration = hash[:duration]
    hash.delete(:duration)
    super
    init_timer(:Quarter)
  end
  
  def clear_buff
    clear_aoe
  end
end

class AoE_Boon_Timed < AoE_Boon
  attr_accessor :duration       # duration of this AoE
  
  include Timed
  
  def initialize(hash)
    @duration = hash[:duration]
    hash.delete(:duration)
    super
    init_timer(:Quarter)
  end
  
end

class AoE_Curse_Timed < AoE_Curse
  attr_accessor :duration       # duration of this AoE
  
  include Timed
  
  def initialize(hash)
    @duration = hash[:duration]
    hash.delete(:duration)
    super
    init_timer(:Quarter)
  end
  
  def clear_buff
    clear_aoe
  end

  
end

