class ArtifactScene
  def initialize(ar, emp=nil)
    artifact_count = ar.length
    @emp = emp
    rows = (artifact_count.to_f / 4).ceil
    cols = (artifact_count.to_f / rows).ceil
    @parts = []
    @boxes = []
    @ys = []
    ystack = 0
    counter = 0
    vp = $scene.spriteset.viewport3
    
    for r in 1..rows
      @parts.push([])
      @boxes.push([])
      @ys.push(0)
      for c in 1..cols
        @parts[r-1].push(ar[counter])
        ib = Infobox.new(vp)
        ib.update(ar[counter])
        @ys[r-1] = ib.bitmap.height if @ys[r-1] < ib.bitmap.height
        @boxes[r-1].push(ib)
        counter += 1
        break if counter == ar.length
      end
      ystack += @ys[r-1]
      break if counter == ar.length
    end
    # ideal start at 140
    @y_start = 0
    @y_slice = 10
    rem = $Screen_H - ystack - @y_slice*(rows-1)
    if rem >= 140
      @y_start = 140
      rem -= 140
      @y_slice += (rem/(rows-1)).cap(40) if rows > 1
    else
      @y_start = rem
    end
    
    rem2 = $Screen_W - 256*cols
    x_slice = rem2 / (cols+1)
    x_start = 0+x_slice
    
    y_stacker = 0
    for r in 0..(@boxes.length-1)
      y = @y_start + y_stacker
      x_width = (256+x_slice)*@boxes[r].length + x_slice
      rem3 = ($Screen_W - x_width)/2
      x = x_start + rem3
      for i in 0..(@boxes[r].length-1)
        @boxes[r][i].z = 9000
        @boxes[r][i].y = y + @y_slice*r
        if r > 0
          @boxes[r][i].y += @ys[r-1]
        end
        @boxes[r][i].x = x + (256+x_slice)*i
      end
    end
    
    @darken = new_hex_sprite
    @darken.z = 8999
    @darken.bitmap = RPG::Cache.icon("scene.png")
    
  end
  
  def choose(x, y)
    # too high?
    return nil if y < @y_start
    y_rolling = 0+@y_start
    y_ind = -1
    for i in 0..(@ys.length-1)
      if y.between?(y_rolling, y_rolling+@ys[i])
        y_ind = i
        break
      end
      y_rolling += @ys[i] + @y_slice
    end
    # not in the right grid
    return nil if y_ind == -1
    # check each box to see if we clicked there
    for i in 0..(@boxes[y_ind].length-1)
      box = @boxes[y_ind][i]
      if x.between?(box.x, box.x+box.bitmap.width) && y.between?(box.y, box.y+box.bitmap.height)
        a = @parts[y_ind][i].new
        a.empower_with(@emp) if @emp
        $player.give_artifact(a)
        clear
        return
      end
    end
    return nil
  end
  
  def clear
    @darken.dispose
    for r in @boxes
      for i in r
        i.dispose
      end
    end
    $artifact_scene = nil
  end
end
$artifact_scene = nil