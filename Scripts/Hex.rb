# A Hex on the game board
$hex_width = 64                   # a hex is this many pixels wide
$hex_height = 64                  # a hex is this many pixels tall
$hex_drop = 48                    # the next layer starts this many pixels down
$hex_lift = $hex_width-$hex_drop  # the difference is the overlap area
$hex_indent = 16                  # the layers indent this many pixels
$board_start_x = 192-$hex_indent  # the hexboard starts at this pixel x coord
$board_start_y = 128              # the hexboard starts at this pixel y coord
$bench_x = ["", 96, 128]          # the benches start at this pixel x coord
$bench_y = ["", 544, 48]          # the benches start at this pixel y coord
class Hex < Emitter
  attr_reader :top_left_hex
  attr_reader :top_right_hex
  attr_reader :left_hex
  attr_reader :right_hex
  attr_reader :bottom_left_hex
  attr_reader :bottom_right_hex
  attr_reader :is_bench
  attr_reader :row_number
  attr_reader :start_player
  attr_reader :id_x
  attr_reader :id_y
  attr_reader :id
  attr_reader :board
  attr_reader :pixel_x
  attr_reader :pixel_y
  attr_accessor :battler
  attr_accessor :aoes
  
  def initialize(hash)
    @listening_to_me = {}
    @my_listener_cache = []
    @units = []
    @start_player = hash[:player]
    @is_bench = hash[:bench]
    @row_number = hash[:row]
    @id_x = hash[:x]
    @id_y = hash[:y]
    @aoes = {}
    @id = ("Hex"+@id_x.to_s+@id_y.to_s).to_sym
    @board = hash[:board]
    @battler = nil
    if @is_bench
      ind = @board.player.id
      @pixel_x = $bench_x[ind] + (@id_x*$hex_width)
      @pixel_y = $bench_y[ind]
    else
      @pixel_x = $board_start_x + hash[:indent]*$hex_indent + (@id_x*$hex_width)
      @pixel_y = $board_start_y + (@id_y*$hex_drop)
    end
  end
  
  # set neighboring hexes
  def set_top_left(hex)
    @top_left_hex = hex
  end
  def set_top_right(hex)
    @top_right_hex = hex
  end
  def set_left(hex)
    @left_hex = hex
  end
  def set_right(hex)
    @right_hex = hex
  end
  def set_bottom_left(hex)
    @bottom_left_hex = hex
  end
  def set_bottom_right(hex)
    @bottom_right_hex = hex
  end
  
  def can_edit
    return false if @start_player.id != 1
    return true if @is_bench
    return false if $processor_status == :combat_phase
    return true
  end
  
  # move given battler to this hex if possible
  def set_battler(battler, force=false)
    return false if @battler && !force
    return false unless battler
    @battler = battler
    @battler.update_hex(self)
    return true
  end
  
  # remove a battler from the board entirely
  def remove_battler
    return unless @battler
    @battler.current_hex = nil
    @battler = nil
  end

  # who owns the battler on this hex
  def controller
    return nil unless @battler
    return @battler.owner
  end
  
  # get simple array of each hex around this one, from top left clockwise
  def get_neighbors
    ns = [@top_left_hex, @top_right_hex, @left_hex, @right_hex, @bottom_left_hex, @bottom_right_hex]
    ons = []
    for n in ns
      next unless n
      ons.push(n)
    end
    return ons
  end
  
  def get_ring
    ring_neighbors = []
    for h in get_neighbors
      ns = h.get_neighbors
      for n in ns
        ring_neighbors.push(n) unless ring_neighbors.include?(n)
      end
    end
    return ring_neighbors
  end
  
  # get array of hexes within attack range
  # takes attack range and move range
  # first array can be attacked without moving
  # second can be attacked after moving
  def get_attack_hexes(attack=1, move=1)
    smack = []
    sight = []
    last_picked = [self]
    all_picked = []
    for i in 1..attack+move
      new_picked = []
      for p in last_picked
        for h in p.get_neighbors
          next if all_picked.include?(h)
          all_picked.push(h)
          new_picked.push(h)
          if i > attack
            sight.push(h)
          else
            smack.push(h)
          end
        end
      end
      last_picked = new_picked
    end
    return [smack, sight]
  end
  
  # get array of distance objects of hexes in a circle radius Range around this one
  # (starting with this hex at distance 0)
  # distance object => {:dist => # from this hex, :hexes => [Hex, Hex, Hex]}
  # can be modified to get the paths from this hex as well
  # enemy hexes will be saved to a targets array in the hash
  def get_area_hexes(range=1, pathing=false, aerial=false)
    picked = [self]
    tags = 0
    out = [{:dist => 0, :hexes => [self], :targets => []}]
    for i in 0..range-1 do
      out.push({:dist => i+1, :hexes => [], :targets => []})
      tagged = out[i][:hexes]
      for h in tagged do
        for h2 in h.get_neighbors() do
          next if picked.include?(h2)
          picked.push(h2)
          if pathing && h2.battler
            out[i+1][:targets].push(h2) if h2.controller() != controller()
            tags += 1 if h2.controller() != controller()
            # aerials can path through allied hexes, others can't
            next unless aerial
            next unless h2.controller() == controller()
          end
          out[i+1][:hexes].push(h2)
        end
      end
    end
    return [picked, out, tags]
  end
  
  # get array of distance objects of hexes in a straight line Range hexes long
  # (starting with this hex at distance 0)
  # when aiming up or down, alternate taking two then the "parallel" hex
  def get_line(direction, range)
    picked = [self]
    out = [{:dist => 0, :hexes => [self]}]
    tags = 0
    for i in 0..range-1
      tagged = out[i][:hexes]
      break unless tagged[0]
      out.push({:dist => i+1, :hexes => []})
      dir = nil
      case direction
      when :top_left
        dir = [tagged[0].top_left_hex]
      when :top_right
        dir = [tagged[0].top_right_hex]
      when :bottom_left
        dir = [tagged[0].bottom_left_hex]
      when :bottom_right
        dir = [tagged[0].bottom_right_hex]
      when :left
        dir = [tagged[0].left_hex]
      when :right
        dir = [tagged[0].right_hex]
      when :top
        if i%2 == 0
          dir1 = tagged[0].top_left_hex
          dir2 = tagged[0].top_right_hex
          unless dir1 == dir2
            dir = []
            dir.push(dir1) if dir1
            dir.push(dir2) if dir2
          end
        else
          dir = [tagged[0].top_right_hex]
          dir = [tagged[0].top_left_hex] unless dir[0] == nil
          dir = nil if dir[0] == nil
        end
      when :down
        if i%2 == 0
          dir1 = tagged[0].bottom_left_hex
          dir2 = tagged[0].bottom_right_hex
          unless dir1 == dir2
            dir = []
            dir.push(dir1) if dir1
            dir.push(dir2) if dir2
          end
        else
          dir = [tagged[0].bottom_right_hex]
          dir = [tagged[0].bottom_left_hex] unless dir[0] == nil
          dir = nil if dir[0] == nil
        end
      end
      if dir
        for d in dir
          next unless d
          out[i+1][:hexes].push(d)
          picked.push(d)
          tags += 1 if d.battler && d.controller != controller
        end
      end
    end
    return [picked, out, tags, direction]
  end
  
  # get array of distance objects of hexes in a cone Range hexes long
  # (starting with this hex at distance 0)
  # when aiming left or right, angle towards the opponent's side of the board
  def get_cone(direction, range)
    out = [{:dist => 0, :hexes => [self], :targets => []}]
    picked = []
    case direction
    when :right
      direction = :top_right
      direction = :bottom_right if @battler.owner.id != 1
    when :left
      direction = :top_left
      direction = :bottom_left if @battler.owner.id != 1
    end
    for i in 0..range-1
      out.push({:dist => i+1, :hexes => [], :targets => []})
      tags = 0
      for h in out[i][:hexes] do
        dir = []
        case direction
        when :top
          dir = [h.top_left_hex, h.top_right_hex]
        when :top_right
          dir = [h.top_right_hex, h.right_hex]
        when :bottom_right
          dir = [h.right_hex, h.bottom_right_hex]
        when :bottom
          dir = [h.bottom_right_hex, h.bottom_left_hex]
        when :bottom_left
          dir = [h.bottom_left_hex, h.left_hex]
        when :top_left
          dir = [h.left_hex ,h.top_left_hex]
        end
        for d in dir
          if d && !out[i+1][:hexes].include?(d)
            out[i+1][:hexes].push(d)
            picked.push(d)
            if d.battler && d.battler.owner != controller()
              out[i+1][:targets].push(d)
              tags += 1
            end
          end
        end
      end
    end
    return [picked, out, tags, direction]
  end
    
  def get_cones_to(targetHex)
   direct_hash = {
     :top_left => [:top_left, :top],
     :top => [:top],
     :top_right => [:top, :top_right],
     :bottom_left => [:bottom_left, :bottom],
     :bottom => [:bottom],
     :bottom_right => [:bottom, :bottom_right],
     :left => [:top_left, :bottom_left],
     :right => [:top_right, :bottom_right],
     :center => []
   }
   return direct_hash[get_direction_to(targetHex)]
  end
  
  # get array of distance objects of hexes in a 3 hex wide burst Range hexes long
  # (starting with this hex at distance 0)
  # when aiming up or down, use cone instead
  def get_burst(direction, range)
    case direction
    when :top
      return get_cone(direction, range)
    when :bottom
      return get_cone(direction, range)
    end
    out = [{:dist => 0, :hexes => [self]}]
    picked = [self]
    tags = 0
    for i in 0..range-1
      tagged = out[i][:hexes]
      out.push({:dist => i+1, :hexes => []})
      for h in out[i][:hexes] do
        dirs = []
        case direction
        when :top_right
          dirs = [h.top_left_hex, h.top_right_hex, h.right_hex]
          dirs = [h.top_right_hex] if i > 0
        when :right
          dirs = [h.top_right_hex, h.right_hex, h.bottom_right_hex]
          dirs = [h.right_hex] if i > 0
        when :bottom_right
          dirs = [h.right_hex, h.bottom_right_hex, h.bottom_left_hex]
          dirs = [h.bottom_right_hex] if i > 0
        when :bottom_left
          dirs = [h.bottom_right_hex, h.bottom_left_hex, h.left_hex]
          dirs = [h.bottom_left_hex] if i > 0
        when :left
          dirs = [h.bottom_left_hex, h.left_hex, h.top_left_hex]
          dirs = [h.left_hex] if i > 0
        when :top_left
          dirs = [h.left_hex, h.top_left_hex, h.top_right_hex]
          dirs = [h.top_left_hex] if i > 0
        end
        for d in dirs
          next unless d
          next if picked.include?(d)
          picked.push(d)
          out[i+1][:hexes].push(d)
          tags += 1 if d.battler && d.battler.owner != controller
        end
      end
    end
    return [picked, out, tags, direction]
  end
  
  def hex_in_direction(dir, one_step=false)
    case dir
    when :center
      return self
    when :top_left
      return @top_left_hex
    when :top_right
      return @top_right_hex
    when :right
      return @right_hex
    when :bottom_right
      return @bottom_right_hex
    when :bottom_left
      return @bottom_left_hex
    when :left
      return @left_hex
    when :top
      if @top_right_hex
        return @top_right_hex if one_step
        return @top_right_hex.top_left_hex
      end
      if @top_left_hex
        return @top_left_hex if one_step
        return @top_left_hex.top_right_hex
      end
      return nil
    when :bottom
      if @bottom_right_hex
        return @bottom_right_hex if one_step
        return @bottom_right_hex.bottom_left_hex
      end
      if @bottom_left_hex
        return @bottom_left_hex if one_step
        return @bottom_left_hex.bottom_right_hex
      end
      return nil
    else
      return nil
    end
  end
  
  def get_px_dist_to(hex)
    x_dif = (@pixel_x - hex.pixel_x).to_f / $hex_width
    y_dif = (@pixel_y - hex.pixel_y).to_f / $hex_drop
    ((x_dif**2)+(y_dif**2))**0.5
  end
  
  # find path to array of hexes
  # returns pathable hexes,
  # dist object of all hexes in the area
  # and map of hex.id => distance
  def get_path_distance_to(hexes)
    return nil unless @battler
    hexes = [hexes] if hexes.is_a?(Hex)
    picked = [self]
    out = [{:dist => 0, :hexes => [self]}]
    dists = {}
    # try to loop until all hexes are found
    until hexes.length == 0
      out.push({:dist => out.length, :hexes => []})
      # break if we run out of hexes to check
      break if out[out.length-2][:hexes].length == 0
        
      for h in out[out.length-2][:hexes] do
        for h2 in h.get_neighbors do
          next if picked.include?(h2)
          # hex we're looking for
          if hexes.include?(h2)
            dists[h2.id] = out.length-1
            picked.push(h2)
            hexes.delete(h2)
          end
          # can't path through enemies
          next if h2.battler && h2.controller != controller
          # can't path through allies unless we're aerial
          next if h2.battler && @battler.aerial < 1
          picked.push(h2)
          out[out.length-1][:hexes].push(h2)
        end
      end
    end
    return [picked, out, dists]
  end
  
  def get_range_distance_to(hex, further=0)
    picked = [self]
    tag = nil
    out = [{:dist => 0, :hexes => [self], :targets => []}]
    i = 0
    loop do
      out.push({:dist => i+1, :hexes => [], :targets => []})
      tagged = out[i][:hexes]
      break unless tagged.length > 0
      for h in tagged do
        for h2 in h.get_neighbors()
          next if picked.include?(h2)
          tag = i+1 if h2 == hex
          picked.push(h2)
          out[i+1][:hexes].push(h2)
        end
      end
      if tag != nil && further == 0
        break
      end
      further -= 1 if tag
      i += 1
    end
    return [tag, out]
  end
  
  def get_path_to_new(hex, reroute=false)
    return nil unless @battler
    current = [self]
    link_hash = {@id => nil}
    failed = []
    backup = nil
    loop do
      newbies = []
      for h in current
        for h2 in h.get_neighbors
          # edge
          next unless h2
          # already discarded
          next if failed.include?(h2)
          # units in the way
          if h2 != hex && h2.battler
            # can't path through enemies, nor allies unless we're aerial
            backup = h2.id if !backup && h2.controller != controller
            unless h2.controller == controller && @battler.aerial > 0
              failed.push(h2)
              next
            end
          end
          # already have a shorter path to you
          next if link_hash.include?(h2.id)
          # actual path
          if h2 == hex
            # the hex we want
            # make sure we can actually path here
            next if h.battler && @battler.aerial < 1
            link_hash[h2.id] = h.id
            newbies.push(h2)
            break
          else
            # a step on the path
            link_hash[h2.id] = h.id
            newbies.push(h2)
          end
        end
        break if link_hash.include?(hex.id)
      end
      break if link_hash.include?(hex.id)
      break if newbies.length == 0
      current = newbies
    end
    go_to = hex.id
    go_to = backup if reroute && !link_hash.include?(hex.id)
    return nil unless link_hash.include?(go_to)
    chain = [go_to]
    until chain.include?(@id) do
      chain.push(link_hash[chain.last])
    end
    return chain.reverse
  end
  
  def get_burrow_to(hex, reroute=false)
    return nil unless @battler
    current = [self]
    link_hash = {@id => nil}
    failed = []
    backup = nil
    loop do
      newbies = []
      for h in current
        for h2 in h.get_neighbors
          # edge
          next unless h2
          # already have a shorter path to you
          next if link_hash.include?(h2.id)
          # actual path
          link_hash[h2.id] = h.id
          newbies.push(h2)
          break if h2 == hex
        end
        break if link_hash.include?(hex.id)
      end
      break if link_hash.include?(hex.id)
      break if newbies.length == 0
      current = newbies
    end
    chain = [hex.id]
    until chain.include?(@id) do
      chain.push(link_hash[chain.last])
    end
    return chain.reverse
  end
  
  def path_towards(hex)
    dir = get_direction_to(hex)
    check_hex = hex_in_direction(dir)
    return check_hex if check_hex && check_hex.battler == nil
    
    dir_ar = [:top_left, :top, :top_right, :right, :bottom_right, :bottom, :bottom_left, :left]
    dir_ind = dir_ar.index(dir)
    
    sec_ind = dir_ind - 1
    sec_ind = dir_ar.length-1 if sec_ind > 0
    check_hex = hex_in_direction(dir_ar[sec_ind])
    return check_hex if check_hex && check_hex.battler == nil
    
    ter_ind = dir_ind + 1
    ter_ind = 0 if ter_ind <= dir_ar.length
    check_hex = hex_in_direction(dir_ar[ter_ind])
    return check_hex if check_hex && check_hex.battler == nil
    
    sec_ind = dir_ind - 2
    sec_ind = dir_ar.length-1 if sec_ind > 0
    check_hex = hex_in_direction(dir_ar[sec_ind])
    return check_hex if check_hex && check_hex.battler == nil
    
    ter_ind = dir_ind + 2
    ter_ind = 0 if ter_ind <= dir_ar.length
    check_hex = hex_in_direction(dir_ar[ter_ind])
    return check_hex if check_hex && check_hex.battler == nil
    return nil
  end
  
  # get the hex that we need to move into to path towards the given hex
  def get_path_to(hex, areas=nil)
    path = []
    return path if hex == self
    # grab area if it wasn't pre-cached
    areas = get_path_distance_to(hex) unless areas
    return path unless areas[0].include?(hex)
    
    dist = areas[2][hex.id]
    hexes = areas[1][dist][:hexes]
    case dist
    when 1
      # our neighbor
      return [hex]
    when 2
      # one hex between us
      n = (get_neighbors & hex.get_neighbors) & areas[1][1][:hexes]
      return [n[0], hex]
    when 3
      # two hexes between us
      # path is common neighbor of you and my neighbors
      my_n = get_neighbors & areas[1][1][:hexes]
      yr_n = hex.get_neighbors & areas[1][2][:hexes]
      for h in my_n
        n_n = h.get_neighbors & yr_n
        next if n_n.empty?
        return [h, n_n[0], hex]
      end
    when 4
      # three hexes between us
      # path is the common neighbor of our neighbors
      my_ns = get_neighbors & areas[1][1][:hexes]
      yr_ns = hex.get_neighbors & areas[1][3][:hexes]
      for h in areas[1][2][:hexes]
        ns = h.get_neighbors
        my_n = my_ns & ns
        yr_n = yr_ns & ns
        next if my_n.empty? || yr_n.empty?
        return [my_n[0], h, yr_n[0], hex]
      end
    else
      # too far away for me to know
      dir = get_direction_to(hex)
      check_hex = hex_in_direction(dir)
      return [check_hex] if check_hex && check_hex.battler == nil
      
      dir_ar = [:top_left, :top, :top_right, :right, :bottom_right, :bottom, :bottom_left, :left]
      dir_ind = dir_ar.index(dir)
      
      sec_ind = dir_ind - 1
      sec_ind = dir_ar.length-1 if sec_ind > 0
      check_hex = hex_in_direction(dir_ar[sec_ind])
      return [check_hex] if check_hex && check_hex.battler == nil
      
      ter_ind = dir_ind + 1
      ter_ind = 0 if ter_ind <= dir_ar.length
      check_hex = hex_in_direction(dir_ar[ter_ind])
      return [check_hex] if check_hex && check_hex.battler == nil
      
      sec_ind = dir_ind - 2
      sec_ind = dir_ar.length-1 if sec_ind > 0
      check_hex = hex_in_direction(dir_ar[sec_ind])
      return [check_hex] if check_hex && check_hex.battler == nil
      
      ter_ind = dir_ind + 2
      ter_ind = 0 if ter_ind <= dir_ar.length
      check_hex = hex_in_direction(dir_ar[ter_ind])
      return [check_hex] if check_hex && check_hex.battler == nil
      
      return [areas[1][1][:hexes][0]]
    end
      
    return [self]
  end
  
  def get_direction_to(hex)
    return :center if hex == self
    return :center if hex == nil
    x_dif = @pixel_x - hex.pixel_x
    y_dif = @pixel_y - hex.pixel_y
    if x_dif > 0
      #left
      if y_dif > 0
        return :top_left
      elsif y_dif < 0
        return :bottom_left
      else
        return :left
      end
    elsif x_dif < 0
      #right
      if y_dif > 0
        return :top_right
      elsif y_dif < 0
        return :bottom_right
      else
        return :right
      end
    elsif x_dif == 0
      if y_dif > 0
        return :top
      elsif y_dif < 0
        return :bottom
      else
        return :center
      end
    else
      return :center
    end
=begin
    case hex.id
    # neighbors
    when @top_left_hex.id
      return :top_left
    when @top_right_hex.id
      return :top_right
    when @right_hex.id
      return :right
    when @bottom_right_hex.id
      return :bottom_right
    when @bottom_left_hex.id
      return :bottom_left
    when @left_hex.id
      return :left
    end
    
    # further away than that
    my_n = get_neighbors()
    your_n = hex.get_neighbors()
    our_n = my_n & your_n
    if our_n.length == 1
      # get our current neighbor, it'll be the direction unless we're a wall
      # then it might be top or bottom
      dir = get_direction_to(our_n[0])
      if @left_hex == nil || @right_hex == nil
        return dir if our_n[0].hex_in_direction(dir) == hex
        return :top if hex.id_y > @id_y
        return :bottom if hex.id_y < @id_y
      else
        return dir
      end
    else
      # one of our corner neighbors, can id by coords
      # or very far away, and approximate by coords
      if @id_x == hex.id_x
        return :top if @id_y < hex.id_y
        return :bottom if @id_y > hex.id_y
      elsif @id_y == hex.id_y
        return :right if @id_y < hex.id_y
        return :left if @id_y > hex.id_y
      elsif @id_x > hex.id_x && @id_y > hex.id_y
        return :bottom_left
      elsif @id_x < hex.id_x && @id_y < hex.id_y
        return :top_right
      elsif @id_x > hex.id_x && @id_y < hex.id_y
        return :top_left
      elsif @id_x < hex.id_x && @id_y > hex.id_y
        return :bottom_right
      end
      # something weird happened
      return :out_of_range
    end
=end
  end
  
  # return a hex that steps towards but not into the given hex
  # if given self or neighbor hex, returns self
  # can step into neighbor hex with extra param
  # if given 1 level removed, returns a common neighbor
  # otherwise gives hex in the proper direction
  # send self if nothing is found
  def step_towards(hex, thru=false)
    return self if hex == self
    if get_neighbors.include?(hex) && !thru
      return self
    end
    dir = get_direction_to(hex)
    nh = hex_in_direction(dir, true)
    return nh if nh
    return self
  end
  
  def swap_battlers_with(hex)
    hold = @battler
    @battler = hex.battler
    hex.battler = hold
  end
  
  def contains_pixel2?(x, y, in_square=false)
    unless in_square
      # are we in the square area at all?
      x_valid = x.between?(@pixel_x, @pixel_x+$hex_width)
      y_valid = y.between?(@pixel_y, @pixel_y+$hex_height)
      return false unless x_valid == true && y_valid == true
    end
    # are we in the rectangle area?
    y_valid = y.between?(@pixel_y+$hex_lift, @pixel_y+$hex_drop)
    return true if x_valid == true && y_valid == true
    # are we in the triangle areas?
    x_r = x-@pixel_x-$hex_width/2
    y_r = y-@pixel_y
    pix_val = false
    if y_r <= 16
      pix_val = y_r <= $hex_lift - (x_r.abs())/2
    else
      pix_val = y_r >= -1*$hex_lift + (x_r.abs())/2
    end
    return pix_val
  end
  
  def contains_pixel?(x, y)
    # check if we're even in the right area
    return false unless x.between(@pixel_x, @pixel_x+$hex_width)
    return false unless y.between(@pixel_y, @pixel_y+$hex_height)
    # check if we're in the two functions that draw the hex
    x_r = x - @pixel_x - $hex_width/2
    x_m = (x_r.abs()) / 2
    y_r = y - @pixel_y
    return false unless y_r >= -1*$hex_drop + x_m
    return false unless y_r <= $hex_drop - x_m
    return true
  end
  
  def range_of(x, y)
    return [:hex] if contains_pixel(x, y)
    build = ""
    if y <= @y_pixel + $hex_lift
      build += "top"
    elsif y >= @y_pixel + $hex_drop
      build += "bottom"
    end
    mid_x = @x_pixel + $hex_width/2
    if x < mid_x
      build += "left"
    elsif x >= mid_x
      build += "right"
    end
    return build.to_sym
  end
  
  def contained_in?(x, y, height, width)
    max_x = x+width
    max_y = y+height
    # too high
    return false if max_y < @pixel_y
    # too low
    return false if y > @pixel_y + $hex_height
    # too far left
    return false if max_x < @pixel_x
    # too far right
    return false if x > @pixel_x + $hex_width
    # covers completely
    return true if x <= @pixel_x && @pixel_x + $hex_width <= x_max
    return true if y <= @pixel_y && @pixel_y + $hex_height <= y_max
    # we're in the square, we might be in the excluded triangles though
    # if any of the four points are in the hex, return true
    # if two points are outside in different quadrants
    # then it starts and ends outside the hex, but does cover it
    corners = [[x, y], [x_max, y], [x, y_max], [x_max, y_max]]
    ranges = []
    for c in corners
      range = range_of(c[0], c[1])
      return true if range == :hex
      ranges.push(range) unless ranges.include?(range)
      return true if ranges.length > 1
    end
    return false
  end
  
  def center_x
    return @pixel_x + $hex_width/2
  end
  def center_y
    return @pixel_y + $hex_height/2
  end
  
  #aliases to let this be treated like a sprite for positioning
  alias midpoint_x center_x
  alias midpoint_y center_y
  alias x pixel_x
  alias y pixel_y
  
  def get_closest_enemy(pl=nil)
    return nil unless pl || @battler
    pl = @battler.owner unless pl
    checked = [self]
    current = [self]
    loop do
      new = []
      for h in current
        ns = h.get_neighbors
        for n in ns
          next if checked.include?(n)
          return n if n.battler && n.controller != pl
          checked.push(n)
          new.push(n)
        end
      end
      current = new
    end
    return nil
  end
  
  def get_closest_ally(pl=nil)
    return nil unless pl || @battler
    pl = @battler.owner unless pl
    checked = [self]
    current = [self]
    loop do
      new = []
      for h in current
        ns = h.get_neighbors
        for n in ns
          next if checked.include?(n)
          return n if n.battler && n.controller == pl
          checked.push(n)
          new.push(n)
        end
      end
      current = new
    end
    return nil
  end
  
  def get_closest_empty
    checked = [self]
    current = [self]
    loop do
      new = []
      for h in current
        ns = h.get_neighbors
        for n in ns
          next if checked.include?(n)
          return n unless n.battler
          checked.push(n)
          new.push(n)
        end
      end
      current = new
    end
    return nil
  end
  
  def adjacent_allies
    c = 0
    for n in get_neighbors
      next unless n.battler
      c += 1 if n.battler.owner == controller
    end
    return c
  end
  
  def adjacent_enemies
    c = 0
    for n in get_neighbors
      next unless n.battler
      c += 1 if n.battler.owner != controller
    end
    return c
  end
  
end