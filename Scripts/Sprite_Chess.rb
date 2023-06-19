class Sprite_Scheduler < RPG::Sprite
  attr_accessor :on_mouse       # is this sprite on the mouse?
  attr_accessor :wild_shot
  attr_accessor :locked_on
  attr_accessor :mark_dispose
  attr_accessor :launch_keys
  attr_accessor :schedules
  attr_accessor :subsprites
  attr_accessor :unit
  attr_accessor :shout
  attr_accessor :holder         # holder for some arbitrary attribute of this sprite
  
  def initialize(viewport)
    @step_counter = 0
    @mark_dispose = 0
    @schedules = [[]]
    @subsprites = []
    super
  end
  
  def dispose
    for s in subsprites
      s.dispose
    end
    super
  end
  
  def vis(bool)
    return if disposed?
    self.visible = bool
    for s in subsprites
      next if s.disposed?
      s.visible = bool
    end
  end
  
  def lift(amount)
    self.z += amount
    for s in subsprites
      s.z += amount
    end
  end
  
  def update
    return if self.disposed?
    if @on_mouse
      # move center to mouse pos
      screen_x, screen_y = Mouse.pos
      hold_x = self.x
      hold_y = self.y
      self.x = screen_x - self.bitmap.width / 2
      self.y = screen_y - self.bitmap.height / 2
      dif_x = self.x - hold_x
      dif_y = self.y - hold_y
      for s in @subsprites
        s.x += dif_x
        s.y += dif_y
      end
    end

    
    for s in @schedules
      next unless s.length > 0
      o = s[0].modify_sprite(self)
      if s[0].iterations < 1
        s[1].previous = o if s[1]
        s.delete_at(0)
      end
      if o[:ret]
        @schedules = [[]]
        return
      end
    end
  end

  # add new schedule and return its index
  def add_schedule
    @schedules.push([])
    return @schedules.length-1
  end
  
  # add snap to specific pixel
  def add_snap(x, y, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:snap)
    ins.x = x
    ins.y = y
    sch.push(ins)
    return schedule
  end
  
  # stick on a sprite, even if it moves
  def add_stick_to(target, duration=0, x_off=0, y_off=0, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:snap)
    ins.target = target
    ins.iterations = duration
    if duration == 0
      ins.iterations = 1
      ins.indefinite = true
    end
    ins.x_off = x_off
    ins.y_off = y_off
    sch.push(ins)
    return schedule
  end
  
  # change the z index
  def add_z(new_z, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:z)
    ins.x = new_z
    sch.push(ins)
    return schedule
  end
  
  # add translate (x, y) pixels in steps frames
  def add_translate(x, y, steps=1, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    x_move = x.to_f
    y_move = y.to_f
    x_step = (x_move/steps).floor
    y_step = (y_move/steps).floor
    x_exc = (x_move - (x_step*steps))/steps
    y_exc = (y_move - (y_step*steps))/steps
    x_ticker = 0
    y_ticker = 0
    for i in 1..steps
      ins = AniInstr.new(:translate)
      ins.x = x_step
      ins.y = y_step
      if x_exc
        x_ticker += x_exc
        if x_ticker >= 1
          a = x_ticker.floor
          ins.x += a
          x_ticker -= a
        end
      end
      if y_exc
        y_ticker += y_exc
        if y_ticker >= 1
          a = y_ticker.floor
          ins.y += a
          y_ticker -= a
        end
      end
      unless i == 1
        prev = sch.last
        if prev.x == ins.x && prev.y == ins.y
          prev.iterations += 1
          next
        end
      end
      sch.push(ins)
    end
    return schedule
  end
  
  # add translate to (target.x, target.y) in steps, following it as it moves
  def add_slide_to(target, steps=1, x_off=nil, y_off=nil, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:aim)
    ins.target = target
    ins.x = target.x
    ins.y = target.y
    ins.x_off = x_off if x_off
    ins.y_off = y_off if y_off
    ins.iterations = steps
    sch.push(ins)
    return schedule
  end
  
  # reduce a sprite's opacity
  def add_fade_to(final_op=0, steps=1, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:opacity)
    ins.x = final_op
    ins.iterations = steps
    sch.push(ins)
  end
  
  def add_fading(start_op, end_op=0, steps=$frames_per_second, duration=0, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:opacity)
    ins.x = end_op
    ins.y = start_op
    ins.x_off = duration
    ins.y_off = steps
    ins.iterations = steps
    sch.push(ins)
  end
  
  # add translate to (x, y) in steps
  def add_move_to(x, y, steps=1, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:aim)
    ins.x = x
    ins.y = y
    ins.iterations = steps
    sch.push(ins)
    return schedule
  end
  
  # add random movement (-x..x, -y-y) for duration
  def add_wiggles(x=0, y=0, duration=0, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:wiggle)
    ins.x = x
    ins.y = y
    if duration > 0
      ins.iterations = duration
    else
      ins.indefinite = true
    end
    sch.push(ins)
    return schedule
  end
  
  # add rotate of th_step for duration
  # can change rotation points ox and oy
  def add_rotation(th_step, duration, ox=self.ox, oy=self.oy, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:rotate)
    ins.theta = th_step
    ins.x = ox
    ins.y = oy
    if duration > 0
      ins.iterations = duration
    else
      ins.indefinite = true
    end
    sch.push(ins)
    return schedule
  end
  
  # add spin of th_step degrees for duration
  def add_spin(th_step, duration=0, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:spin)
    ins.theta = th_step
    if duration > 0
      ins.iterations = duration
    else
      ins.indefinite = true
    end
    sch.push(ins)
    return schedule
  end
  
  # add orbit around (start.x, start.y) at r distance in steps frames
  # lasts for duration, starts at angle th
  # can change the radius over time with r_step
  def add_orbit(start, r, steps, duration=0, th=0, r_step=0, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:orbit)
    ins.theta_step = 2*Math::PI / steps
    ins.theta = th
    ins.radius = r
    ins.radius_step = r_step
    if start.is_a?(Hash)
      ins.x = start.x
      ins.y = start.y
    else
      ins.target = start
    end
    ins.iterations = duration
    if duration == 0
      ins.indefinite = true
      ins.iterations = 1
    end
    sch.push(ins)
    return schedule
  end

  # resolve a damage event on this hex
  def add_damage(damage_event, style="standard", schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:damage)
    ins.damage = damage_event
    ins.str = style
    sch.push(ins)
    return schedule
  end
  
  # resolve a heal impact on this hex
  def add_heal(target, imp, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:heal)
    ins.target = target
    ins.damage = imp
    sch.push(ins)
    return schedule
  end
  
  # does the stun halo effect
  def add_stun_halo(target, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    return schedule if !target || !target.sprite || target.sprite.disposed?
    sch = @schedules[schedule]
    ins = AniInstr.new(:stun_halo)
    ins.target = target
    ins.radius = 32
    ins.iterations = 1
    ins.indefinite = true
    self.bitmap = RPG::Cache.icon("stunned.png")
    self.ox = self.bitmap.width
    self.oy = self.bitmap.height
    self.x = target.sprite.x + (self.ox/2)
    self.y = target.sprite.y + (self.oy/2)
    self.z = 7000
    ins.theta_step = -5
    sch.push(ins)
    return schedule
  end
  
  def add_scan(max_theta, steps, duration=0, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:arc)
    ins.iterations = duration
    if duration == 0
      ins.iterations = 1
      ins.indefinite = true
    end
    ins.theta_step = max_theta/steps
    larger = self.angle
    smaller = self.angle+max_theta
    if larger < smaller
      larger = self.angle+max_theta
      smaller = self.angle
    end
    ins.x = larger
    ins.y = smaller
    sch.push(ins)
    return schedule
  end
  
  # wait for duration frames
  def add_wait(duration, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    return schedule if duration == 0
    sch = @schedules[schedule]
    ins = AniInstr.new(:wait)
    ins.iterations = duration
    sch.push(ins)
    return schedule
  end
  
  # toggle this sprite's visibility
  def switch_visible(schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    sch.push(AniInstr.new(:visible))
    return schedule
  end
  
  # dispose this sprite
  def add_dispose(schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    sch.push(AniInstr.new(:dispose))
    return schedule
  end

  def add_change_bitmap(bitmap, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:bitmap)
    ins.target = bitmap
    sch.push(ins)
  end
  
  def add_proc(proc, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:proc)
    ins.target = proc
    sch.push(ins)
  end
  
  def add_uproot(target=@unit, amount=1, schedule=0)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:uproot)
    ins.target = target
    ins.x = amount
    sch.push(ins)
  end
  
  def pop(sym, schedule=0, all=false)
    sch = @schedules[schedule]
    return false unless sch
    for ani in sch
      if ani.instruction == sym
        sch.delete(ani)
        break unless all
      end
    end
  end
  
  # sometimes scripts want to be recalculated partway through movement
  # this allows that to happen
  # currently not supported cause not sure if needed actually
  def add_meta_script(key, schedule, *args)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    ins = AniInstr.new(:meta)
    ins.meta_main = [key, schedule]
    ins.meta_instr = args
    @schedules[schedule].push(ins)
    return schedule
  end
  
  def match_vis(target, schedule)
    unless @schedules.length > schedule
      schedule = @schedules.length
      @schedules.push([])
    end
    sch = @schedules[schedule]
    ins = AniInstr.new(:visible)
    ins.target = target
    sch.push(ins)
  end
  
  def center_on(sprite)
    self.ox = center_x
    self.oy = center_y
    self.x = sprite.midpoint_x
    self.y = sprite.midpoint_y
  end
  
  # half the sprite width
  def center_x
    return 0 unless self.bitmap
    return self.bitmap.width/2
  end
  # half the sprite height
  def center_y
    return 0 unless self.bitmap
    return self.bitmap.height/2
  end
  # pixel_x position of the sprite's center
  def midpoint_x
    return self.x + center_x - self.ox
  end
  # pixel_y position of the sprite's center
  def midpoint_y
    return self.y + center_y - self.oy
  end
  
  def create_clone(new_target, old_target)
    clone_spr = new_animation_sprite
    clone_spr.bitmap = self.bitmap
    clone_spr.x = self.x
    clone_spr.y = self.y
    clone_spr.ox = self.ox
    clone_spr.oy = self.oy
    for sc in @schedules
      ns = clone_spr.add_schedule
      for ins in sc
        cl_ins = AniInstr.new(ins.instruction)
        cl_ins.iterations = ins.iterations
        cl_ins.x = ins.x
        cl_ins.y = ins.y
        cl_ins.x_off = ins.x_off
        cl_ins.y_off = ins.y_off
        cl_ins.theta = ins.theta
        cl_ins.theta_step = ins.theta_step
        cl_ins.radius = ins.radius
        cl_ins.radius_step = ins.radius_step
        cl_ins.previous = ins.previous
        cl_ins.target = (ins.target == old_target ? new_target : ins.target)
        cl_ins.damage = ins.damage
        cl_ins.indefinite = ins.indefinite
        cl_ins.meta_main = ins.meta_main
        cl_ins.meta_instr = ins.meta_instr
        cl_ins.bool = ins.bool
        cl_ins.str = ins.str
      end
      clone_spr.schedules[ns].push(cl_ins)
    end
    return clone_spr
  end

end

class Sprite_Chess < Sprite_Scheduler
end

def to_radians(num)
  return (num.to_f / 180) * Math::PI
end

def to_degrees(num)
  return 180 * num / Math::PI
end

def new_animation_sprite(cl=Sprite_Chess)
  return $scene.spriteset.add_anim_to_port(cl)
end

def new_hex_sprite(cl=Sprite_Chess)
  return $scene.spriteset.add_hex_to_port(cl)
end

def angle_of(sprite1, sprite2)
  x1 = sprite1.midpoint_x
  x2 = sprite2.midpoint_x
  y1 = sprite1.midpoint_y
  y2 = sprite2.midpoint_y
  
  x_diff = x2 - x1
  y_diff = y2 - y1
  if x_diff == 0
    return 90 if y_diff < 0
    return 270
  elsif y_diff == 0
    return 180 if x_diff < 0
    return 0
  else
    self_angle = to_degrees(Math.atan(y_diff.abs().to_f / x_diff.abs()))
    return 360 - self_angle if x_diff > 0 && y_diff > 0
    return self_angle if x_diff > 0 && y_diff < 0
    return 180 - self_angle if x_diff < 0 && y_diff < 0
    return 180 + self_angle if x_diff < 0 && y_diff > 0
  end
end