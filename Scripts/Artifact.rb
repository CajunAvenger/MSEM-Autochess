class Artifact < Emitter
  attr_reader :name             # string name of this artifact
  attr_accessor :displayname    # string display name of this artifact
  attr_reader :owner            # owner of this artifact
  attr_reader :cost             # cost of this artifact
  attr_accessor :impacts        # impacts managed by this artifact
  attr_reader :keys             # aesthetic keys of this artifact
  attr_reader :slots            # number of slots this takes, usually 1
  attr_reader :type             # symbol of this artifact's type
  attr_reader :component        # is this a component?
  attr_reader :completed        # is this completed?
  attr_reader :rare             # is this rare?
  attr_accessor :wielder        # current wielder of this artifact
  attr_accessor :sprite         # this sprite
  attr_accessor :empowered      # is this artifact empowered in some way?
  attr_accessor :damage_dealt
  attr_accessor :font_size
  
  include Enchantable

  def self.get_base_stats
    return {
      :name       => "Unnamed", # string name
      :description => "Someone forgot " + 
                      "to give this a description.",
      :type       => :dummy,    # SYMBOL! can be :component, :completed, or :rare.
      :keys       => [],        # various keys that other things can reference
      :components => [],        # array of string names if complete
      :impacts => [],           # impacts this needs to create
      # formatted [[class, [args]]], ex
      # [[Impact, [:POWER, 10]]] for basic +10 Power,
      # [[Impact, [:MANA_AMP, 10]], [Impact, [:ARCHIVE, 10]]]
      #   for +10 Mana Amp, +10 Archive, or
      # [[Impact_Warhammer, [:POWER, 10, 1, 2, 0]]]
      #   for the Alenian Warhammer buff
      :back   => [:UNIQUE]       # bitmap parts
    }
  end
  
  def self.main_bitmap
    name = get_base_stats[:name]
    return RPG::Cache.icon("Artifacts/"+name+".png")
  end
  
  def self.backdrop_bitmap
    back = get_base_stats[:back] || [:UNIQUE]
    b1 = back.first
    b2 = back.last
    if !$backdrop_bitmaps[:base][b1][b2]
      b2 = back.first
      b1 = back.last
    end
    if $colorblind
      return $backdrop_bitmaps[:colorblind][b1][b2]
    else
      return $backdrop_bitmaps[:base][b1][b2]
    end
  end
  
  def get_base_stats
    return self.class.get_base_stats
  end
  
  def initialize(placing=nil)
    inherent = get_base_stats
    @listening_to_me = {}
    @my_listener_cache = []
    @name = inherent[:name] || "Unnamed"
    @displayname = inherent[:name] || "Unnamed"
    @cost = inherent[:cost] || 1
    @keys = inherent[:keys] || []
    @cost = inherent[:slots] || 1
    @description = get_description || ["Someone forgot to give this a description."]
    @impacts = build_impacts(inherent[:impacts])
    @type = inherent[:type]
    @component = type == :component
    @completed = type == :completed
    @rare = type == :rare
    @damage_dealt = 0
    @empowered = []
    @font_size = 17
    
    @id_number = get_artifact_id()
    @id = @name + @id_number.to_s
    @wielder = nil
    extra_init
    @backs = inherent[:back] || [:UNIQUE]
    prepare_sprite if placing
  end  
    
  def prepare_sprite(placing=nil)
    @sprite = new_artifact_sprite
    @sprite.visible = false
    @sprite.artifact = self
    @sprite.bitmap = RPG::Cache.icon("Artifacts/"+@name+".png")
    @sprite.z = 7050
    @back_drop = new_artifact_sprite
    if $backdrop_bitmaps[:base][@backs.first][@backs.last]
      @back_drop.b1 = @backs.first
      @back_drop.b2 = @backs.last
    else
      @back_drop.b2 = @backs.first
      @back_drop.b1 = @backs.last
    end
    @back_drop.cb_bitmap
    @back_drop.z = 7049
    @back_drop.add_stick_to(@sprite)
    @back_drop.artifact = self
    @sprite.subsprites.push(@back_drop)
    prepare_sprite(placing) if placing
    time = 1
    if placing.is_a?(Hex)
      time = 0.7*$frames_per_second
      @sprite.x = placing.center_x - 10
      @sprite.y = placing.center_y - 10
      @back_drop.x = placing.center_x - 10
      @back_drop.y = placing.center_y - 10
      @sprite.vis(true)
    elsif placing.is_a?(Artifact)
      time = 0
    end
    $artifact_tray.give(@sprite, time)
  end
  
  def extra_init
  end
  
  # make this a method so you can define updating descriptions
  
  def self.get_description
    return [@description]
  end
  
  def get_description
    return self.class.get_description
  end
  
  def build_impacts(imp_arrays)
    ar = []
    for ma in imp_arrays
      ar.push(ma[0].new(*ma[1]))
    end
    return ar
  end
  
  def use_slots
    return 1
  end

  def equip_to(target)
    @wielder = target
    @owner = @wielder.owner
    for impact in @impacts
      impact.register(self, target)
      @wielder.add_impact(impact)
    end
    emit(:EquippedTo, target)
  end
  
  def unequip_from(dont_trigger = false)
    for impact in @impacts
      impact.register(self, nil)
      @wielder.remove_impact(impact)
    end
    @wielder = nil
    emit(:UnequippedFrom, @target) unless dont_trigger
  end
  
  def components
    return []
  end
  
  def is_component
    return @component
  end
  
  def is_completed
    return @completed
  end
  
  def is_rare
    return @rare
  end
  
  # kill the artifact
  def clear_artifact
    @wielder.remove_artifact(self)
    clear_listeners()
    @owner = nil
    @source = nil
    @impacts = nil
    @sprite.dispose if @sprite
    @back_drop.dispose if @back_drop
  end
  
  def self.has_infobox?
    return true
  end
  
  def self.write_to_infobox(infobox, extra=nil)
    text = get_base_stats[:name]

    if text != infobox.cached_text
      infobox.cached_text = text
      infobox.submenu = nil
      desc = get_description
      infobox.bitmap = Bitmap.new("Graphics/Icons/Infobox_"+desc.length.cap(8).to_s+".png")
      infobox.bitmap.font.name = "Fontin"
      infobox.bitmap.font.size = 17
      infobox.bitmap.font.color.set(255,255,255)
      infobox.bitmap.blt(10, 5, backdrop_bitmap, Rect.new(0, 0, 22, 22))
      infobox.bitmap.blt(10, 5, main_bitmap, Rect.new(0, 0, 22, 22))
      infobox.bitmap.draw_text(35, 6, 256, 24, text)
      
      y_start = 30
      for d in desc
        infobox.bitmap.draw_text(10, y_start, 256, 24, d)
        y_start += 20
      end
    end
  end

  
  def has_infobox?
    return true
  end
  
  def write_to_infobox(infobox, extra=nil)
    text = @displayname

    if text != infobox.cached_text
      infobox.cached_text = text
      infobox.submenu = nil
      desc = @description
      if @component
        infobox.bitmap = Bitmap.new("Graphics/Icons/Infobox_large.png")
      else
        infobox.bitmap = Bitmap.new("Graphics/Icons/Infobox_"+desc.length.cap(8).to_s+".png")
      end
      infobox.bitmap.font.name = "Fontin"
      if !@font_size
        infobox.bitmap.font.size = 17
        infobox.bitmap.shrink_to(@displayname, 215)
        @font_size = infobox.bitmap.font.size
      end
      infobox.bitmap.font.size = @font_size
      infobox.bitmap.font.color.set(255,255,255)
      infobox.bitmap.blt(10, 5, @back_drop.bitmap, Rect.new(0, 0, 22, 22))
      infobox.bitmap.blt(10, 5, @sprite.bitmap, Rect.new(0, 0, 22, 22))
      infobox.bitmap.draw_text(35, 6, 256, 24, @displayname)
      
      y_start = 30
      infobox.bitmap.font.size = 17
      for d in desc
        infobox.bitmap.draw_text(10, y_start, 256, 24, d)
        y_start += 20
      end
      if $artifacts[:build_map][@name]
        infobox.submenu = self
        build_order = [@name] + ($component_names - [@name])
        for second_name in build_order
          build_class = $artifacts[:name_map][second_name]
          builds = $artifacts[:build_map][@name][second_name]
          infobox.bitmap.blt(10, y_start, build_class.backdrop_bitmap, Rect.new(0,0,22,22))
          infobox.bitmap.blt(10, y_start, build_class.main_bitmap, Rect.new(0,0,22,22))
          infobox.bitmap.blt(40, y_start, builds.backdrop_bitmap, Rect.new(0,0,22,22))
          infobox.bitmap.blt(40, y_start, builds.main_bitmap, Rect.new(0,0,22,22))
          y_start += 24
        end
        if @empowered.include?(:verdant)
          infobox.bitmap.draw_text(70, 50, 184, 24, "Verdant:")
          infobox.bitmap.draw_text(70, 74, 184, 24, "Completed artifacts this")
          infobox.bitmap.draw_text(70, 98, 184, 24, "builds grant bonus power,")
          infobox.bitmap.draw_text(70, 122, 184, 24, "toughness, and mana amp.")
        end
      end
    end
  end
  
  def get_submenu
    # component submenu
    build_order = [@name] + ($component_names - [@name])
    x, y = *Mouse.pos
    x_rcn = x - $infobox.x 
    y_rcn = y - $infobox.y - 45
    return nil if y_rcn < 0
    y_ind = y_rcn / 24
    return nil if y_ind >= build_order.length
    return nil if 10 > x_rcn || x_rcn.between?(33, 39) || x_rcn > 62
    builder = build_order[y_ind]
    if x_rcn < 40
      return $artifacts[:name_map][builder]
    else
      return $artifacts[:build_map][@name][builder]
    end
  end
  
  def empowered?
    return @empowered.length > 0
  end
  
  def empower_from(a1, a2)
    emps = a1.empowered + a2.empowered
    for e in emps
      empower_with(e)
    end
  end
  
  def empower_with(e)
    case e
    when :verdant
      unless @empowered.include?(:verdant)
        @empowered.push(:verdant)
        @displayname = "Verdant " + @displayname
        @font_size = nil
        @description.push("Verdant: Grants bonus power,")
        @description.push("toughness, and mana amp.")
      end
      @impacts.push(Impact.new(:POWER, 20))
      @impacts.push(Impact.new(:TOUGHNESS, 20))
      @impacts.push(Impact.new(:MANA_AMP, 20))
    when :uncovered
      unless @empowered.include?(:uncovered)
        @empowered.push(:uncovered)
        @displayname = "Uncovered " + @displayname
        @font_size = nil
        @description.push("Uncovered: Grants bonus archive.")
      end
      @impacts.push(Impact.new(:ARCHIVE, 20))
    end
  end
  
  # dummy values so artifact can be a damage source
  def get_value(key)
    return 0
  end
  def apply_heal(imp)
  end
  def apply_anti_heal(imp)
  end
end

