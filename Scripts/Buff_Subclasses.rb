class Debuff < Buff
  # This just exists as an easy marker
  # Buffs made this way match is_a?(Debuff)
  
  def clone_args(new_target, new_efs)
    return [
      Debuff,
      [@source, new_target, new_efs, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end
end

class Buff_Eternal < Buff
  include Eternal
  
  def clone_args(new_target, new_efs)
    return [
      Buff_Eternal,
      [@source, new_target, new_efs, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end
end

class Buff_Timed < Buff
  include Timed
  def initialize(source, target, effects, duration, name=SELF_DATA[:name], keys=nil)
    return Buff.new(source, target, effects, name, keys) if duration == 0
    @duration = duration*fps
    super(source, target, effects, name, keys)
    init_timer(:Frame)
  end
  
  def clone_args(new_target, new_efs)
    return [
      Buff_Timed,
      [@source, new_target, new_efs, @duration, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end
end

class Buff_Ticker < Buff
  include Timed
  def initialize(source, target, effects, duration, name=SELF_DATA[:name], keys=nil)
    return Buff.new(source, target, effects, name, keys) if duration == 0
    @duration = duration*$ticks_per_second
    super(source, target, effects, name, keys)
    init_timer(:Tick)
  end
  
  def clone_args(new_target, new_efs)
    return [
      Buff_Ticker,
      [@source, new_target, new_efs, @duration, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end

end

class Debuff_Eternal < Debuff
  include Eternal
  
  def clone_args(new_target, new_efs)
    return [
      Debuff_Eternal,
      [@source, new_target, new_efs, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end
end

class Debuff_Timed < Debuff
  include Timed
  def initialize(source, target, effects, duration, name=SELF_DATA[:name], keys=nil)
    return Debuff.new(source, target, effects, name, keys) if duration == 0
    @duration = duration*fps
    super(source, target, effects, name, keys)
    init_timer(:Frame)
  end
  
  def clone_args(new_target, new_efs)
    return [
      Debuff_Timed,
      [@source, new_target, new_efs, @duration, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end
end

class Debuff_Ticker < Debuff
  include Timed
  def initialize(source, target, effects, duration, name=SELF_DATA[:name], keys=nil)
    return Debuff.new(source, target, effects, name, keys) if duration == 0
    @duration = duration * $ticks_per_second
    super(source, target, effects, name, keys)
    init_timer(:Tick)
  end
  
  def clone_args(new_target, new_efs)
    return [
      Debuff_Ticker,
      [@source, new_target, new_efs, @duration, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end
end

class DoT < Debuff
  include Timed
  def initialize(source, target, total_damage, duration, name="Damage over Time", keys=nil)
    @duration = duration*4
    @damage = total_damage.to_f/@duration
    super(source, target, [], name, keys)
    init_timer(:Quarter)
  end
  
  def trigger_effect
    console.log("dot")
    Damage.new(@source, @target, 0, @damage).resolve
  end
  
end