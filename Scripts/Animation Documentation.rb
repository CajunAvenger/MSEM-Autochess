=begin
  add_schedule()
    every frame, do the next instruction in each schedule
    
  TRANSLATE
  add_translate(x, y, steps, schedule)
    move (x, y) pixels in steps frames
  add_move_to(x, y, steps, schedule)
    move to (x, y) in steps frames
  add_snap(x, y, schedule)
    move to (x, y) immediately
  add_stick_to(target, duration, x_off, y_off, schedule)
    follow target for duration frames, (x_off, y_off) px offset
  add_slide_to(target, steps=1, schedule)
    move to (target.x, target.y) in steps frames. Moves with the target
  add_wiggles(x, y, duration, schedule)
    every step, move a random (-x..x, -y..y) for duration frames
    
  ROTATION
  add_rotation(th_step, duration, ox, oy, schedule)
    rotate around self (ox, oy), th_step degrees per frame for duration frames
  add_spin(th_step, duration, schedule)
    rotate around self centerpoint, th_step degrees per frame for duration frames
  add_scan(theta, steps, duration, schedule)
    rotate back and forth theta degrees in steps frames for duration frames
  add_orbit(start, r, steps, duration, th, r_step, schedule)
    rotate around (start.x, start.y) at radius r in steps frames for duration frames
    begin at angle th, change the radius by r_step each frame (both default 0)
    positive r_step causes outward spiral, negative an inward spiral
    
  OTHER
  add_z(z, schedule)
    change the layer of this sprite
  add_fade_to(new_opac, steps, schedule)
    change the opacity to new_opac in steps frames
  add_damage(damage, style, schedule)
    resolve a damage event
    by default, resolves on target if they're in the same hex as the sprite
    style = "locked" resolves regardles of position
    style = "wild shot" changes the target to the current hex and resolves
  add_stun_halo(target, schedule)
    apply stun halo until the target is no longer stunned
  add_wait(duration schedule)
    do nothing for duration frames
  switch_visible(schedule)
    toggle sprite's visibility
  add_dispose
    delete this sprite
    
  TODO
  add_sprite_change
  add_color_change
  add_flash
  add_subsprite
  add_opacity_change
=end