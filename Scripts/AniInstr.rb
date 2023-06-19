class AniInstr
  attr_accessor :instruction
  attr_accessor :iterations
  attr_accessor :x
  attr_accessor :y
  attr_accessor :x_off
  attr_accessor :y_off
  attr_accessor :theta
  attr_accessor :theta_step
  attr_accessor :radius
  attr_accessor :radius_step
  attr_accessor :previous
  attr_accessor :target
  attr_accessor :damage
  attr_accessor :indefinite
  attr_accessor :meta_main
  attr_accessor :meta_instr
  attr_accessor :bool
  attr_accessor :str
  
  def initialize(instr)
    @instruction = instr
    @iterations = 1
    @indefinite = false
    @previous = {}
    @meta_instr = []
    @theta = 0
    @x_off = 0
    @y_off = 0
  end
  # :translate      simple move
  # :wiggle         move a random, small amount
  # :snap           snap to specific coords
  # :rotate         change angle
  # :arc            change an angle back and forth
  # :spin           spin at center
  # :orbit          orbits a targe
  # :visible        toggle visibility
  # :dispose        dispose of this
  # :damage         resolve damage event
  # :heal           resolve heal
  # :wait           wait
  # :visible        change visibility
  # :opacity        change opacity
  # :bitmap         change bitmap
  # :z              change z
  # :uproot         change unit's root status
  # :proc           fire a proc
  # :meta           add a new script
  def modify_sprite(sprite)
    out_data = {}
    case @instruction
    when :translate
      sprite.x += x
      sprite.y += y
    when :aim
      if @target && @target.unit && @target.unit.dead
        sprite.dispose
        out_data[:ret] = true
      else
        if @target && !@target.disposed?
          @x = @target.midpoint_x + @x_off
          @y = @target.midpoint_y + @y_off
        end
        sprite.x += ((@x - sprite.x)/@iterations).floor
        sprite.y += ((@y - sprite.y)/@iterations).floor
      end
    when :opacity
      step = (sprite.opacity - @x)/@iterations
      sprite.opacity -= step
      if @y && @iterations == 1
        hold = @y
        @y = @x
        @x = hold
        @iterations += @y_off
        if @x_off == 1
          @iterations = 1
        elsif @x_off > 0
          @x_off -= 1
        end
      end
    when :wiggle
      sprite.x += rand(2*@x+1) - @x
      sprite.y += rand(2*@y+1) - @y
    when :snap
      if @target
        return if @target.disposed?
        sprite.x = @target.x + @x_off
        sprite.y = @target.y + @y_off
      else
        sprite.x = @x + @x_off
        sprite.y = @y + @y_off
      end
    when :z
      sprite.z = @x
    when :rotate
      sprite.ox = x
      sprite.oy = y
      sprite.angle += theta
    when :stun_halo
      if @target.dead || @target.get_value(:STUN) <= 0
        sprite.dispose
      else
        sprite.angle += @theta_step
        if sprite.angle == -60 or sprite.angle == 0
          @theta_step = -@theta_step
        end
        sprite.visible = true
        sprite.x = @target.sprite.x + (sprite.ox/2)
        sprite.y = @target.sprite.y + (sprite.oy/2)
      end
    when :arc
      sprite.angle += @theta_step
      if sprite.angle >= @x || sprite.angle <= @y
        @theta_step = -@theta_step
      end
    when :spin
      sprite.ox = sprite.center_x
      sprite.oy = sprite.center_y
      sprite.angle += @theta
    when :orbit
      @theta += @theta_step
      @radius += @radius_step
      if @target && !@target.disposed?
        @x = @target.x
        @y = @target.y
      end
      sprite.x = @x + (@radius * Math.cos(@theta))
      sprite.y = @y + (@radius * Math.sin(@theta))
    when :visible
      if @target && @target.disposed?
        sprite.visible = false
      elsif @target
        sprite.visible = @target.visible
      else
        sprite.visible = !sprite.visible
      end
    when :dispose
      sprite.dispose
      out_data[:ret] = true
    when :heal
      if @target && !@target.dead
        if @damage.id == :HEALING
          @target.apply_heal(@damage)
        else
          @target.apply_mana_heal(@damage)
        end
      end
    when :damage
      case @str
      when "enemy"
        mid_x = sprite.midpoint_x
        mid_y = sprite.midpoint_y
        hex = $game_master.hex_from_mouse(mid_x, mid_y)
        if hex && hex.battler && hex.battler.owner != @damage.source.owner
          @damage.clear_targets
          @damage.add_target(hex.battler)
          @damage.resolve()
        end
      when "wild shot"
        mid_x = sprite.midpoint_x
        mid_y = sprite.midpoint_y
        hex = $game_master.hex_from_mouse(mid_x, mid_y)
        if hex && hex.battler
          @damage.clear_targets
          @damage.add_target(hex.battler)
          @damage.resolve()
        end
      when "locked"
        @damage.resolve()
      else
        mid_x = sprite.midpoint_x
        mid_y = sprite.midpoint_y
        hex = $game_master.hex_from_mouse(mid_x, mid_y)
        if hex && @damage.targets.include?(hex.battler)
          @damage.resolve()
        end
      end
    when :visible
      if @target
        sprite.visible = @target.visible
      elsif @bool
        sprite.visible = bool
      else
        sprite.visible = !sprite.visible
      end
    when :bitmap
      sprite.bitmap = @target
    when :uproot
      @target.rooted -= @x
    when :proc
      @target.call()
    when :wait
      # do nothing lmao
    end
    @iterations -= 1 unless @indefinite
    return out_data
  end
  
end