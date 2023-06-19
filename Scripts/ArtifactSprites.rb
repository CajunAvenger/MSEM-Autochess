# the handler for the artifact sprites
class ArtifactTray
  attr_reader :sprites
  
  X_start = 128
  Y_start = 615
  A_width = 20
  A_spacer = 10
  Max_width = 704
  X_width = Max_width - X_start
  A_count = (X_width / (A_width+A_spacer)).floor
  A_drop = 30
  
  def initialize
    @sprites = []
    for i in 0..A_count*4
      @sprites.push(nil)
    end
  end
  
  def give(spr, time=1)
    test_ind = @sprites.index(nil)
    if test_ind
      @sprites[test_ind] = spr
    else
      test_ind = @sprites.length
      @sprites.push(spr)
    end
    move_to_grid(spr, time)
  end
  
  def move_to_grid(sprite, time)
    spr_ind = @sprites.index(sprite)
    y_ind = spr_ind / A_count
    x_ind = spr_ind - y_ind*A_count
    final_x = X_start + (A_width+A_spacer)*x_ind
    final_y = Y_start + A_drop*y_ind
    sprite.add_move_to(final_x, final_y, time) if time > 0
  end
  
  def info_from_pos(x, y)
    x_rcn = x - X_start + 2
    y_rcn = y - Y_start + 2
    x_per = x_rcn % (A_width + A_spacer)
    y_per = y_rcn % (A_drop)
    x_ind = x_rcn / (A_width + A_spacer)
    y_ind = y_rcn / (A_drop)
    if x_per < 27 && y_per < 27 && @sprites[x_ind + A_count*y_ind]
      return @sprites[x_ind + A_count*y_ind]
    else
      return [x_ind, y_ind, x_per > 26, y_per > 26]
    end
  end
  
  # replace slot with nil, return taken sprite
  def take(spr)
    @sprites[@sprites.index(spr)] = nil
    return spr
  end
  
  # swap artifact in the tray with a new one, return the old one
  def swap(tray_spr, new_spr)
    ind = @sprites.index(tray_spr)
    @sprites[ind] = new_spr
    move_to_grid(new_spr, 1)
    Mouse.drop if Mouse.holding? == new_spr
    return tray_spr
  end
  
  def place(sprite, x_ind, y_ind, over_x, over_y)
    main_ind = x_ind + A_count*y_ind
    if @sprites[main_ind] != nil
      x_2 = (over_x ? x_ind+1 : x_ind)
      y_2 = (over_y ? y_ind+1 : y_ind)
      main_ind = x_2 + A_count*y_ind
      if @sprites[main_ind] != nil
        main_ind = @sprites.index(nil)
      end
    end
    if main_ind
      @sprites[main_ind] = sprite
    else
      @sprites.push(sprite)
    end
    move_to_grid(sprite, 1)
  end
  
end

$artifact_tray = ArtifactTray.new