# handles the synergy sprites
class SynergyTray < Emitter
  def initialize(owner)
    @listening_to_me = {}
    @my_listener_cache = []
    @owner = owner
    @index_holder = {}
    @syn_counters = []
    @active_names = {}
    @sorted = []
    @sprites = {}
    @syns = []
    for id, s in @owner.synergy_handlers
      @syns.push(s)
    end
  end
  
  def update
    # sort the array by levels
    all_sort = @syns.sort_by {|s| -s.level.to_f / s.breakpoints.length }
    @sorted = []
    indent = 0
    start_here = 128
    for syn in all_sort
      if syn.show_icon
        @sorted.push(syn)
        @sprites[syn.key] = new_hex_sprite() unless @sprites[syn.key]
        bm = syn.sprite + "_" + syn.level.to_s + ".png"
        @sprites[syn.key].x = 16 + indent
        @sprites[syn.key].y = start_here
        start_here += 36
        if indent == 0
          indent = 24
        else
          indent = 0
        end
        @sprites[syn.key].bitmap = RPG::Cache.icon("Synergy/"+bm)
        @sprites[syn.key].visible = true
      elsif @sprites[syn.key]
        # hide the sprite
        @sprites[syn.key].visible = false
      end
    end
  end
  
  def syn_from_mouse(x, y)
    return nil unless @sorted.length > 0
    x_rcn = x - 16
    y_rcn = y - 136
   
    x_start = 0
    # top jag
    # hexes are in 36px segments
    # top 24 are safe
    # bottom 12 can be one of two hexes
    y_per = y_rcn % 36
    y_ind = y_rcn / 36
    return @sorted[0] if y_rcn.between?(-12, 0)
    return nil if y_ind < 0
    if y_per < 25
      if y_ind % 2 == 1
        x_start += 24
      end
      return @sorted[y_ind] if x_rcn.between?(x_start, x_start+48)
      return nil
    end
    y_rcn_rcn = 36 - y_per
    if y_ind % 2 == 0
      return nil if y_rcn_rcn < 12 - 0.5 * x_rcn
      return nil if y_rcn_rcn > 32 - 0.5 * x_rcn
      return @sorted[y_ind] if y_rcn_rcn > 0.5 * x_rcn - 12
      return @sorted[y_ind+1]
    else
      return nil if y_rcn_rcn > 0.5 * x_rcn
      return nil if y_rcn_rcn < 0.5 * x_rcn - 24
      return @sorted[y_ind] if y_rcn_rcn > 24 - 0.5 * x_rcn
      return @sorted[y_ind+1]      
    end
  end
end