#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc.
#  It's used within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  attr_accessor :character_sprites
  attr_accessor :anim_sprites
  attr_accessor :viewport3
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    # Make viewports
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    $viewport = @viewport3
    # Make tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
    end
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    # Make panorama plane
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    # Make fog plane
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    # Make character sprites
    @character_sprites = []
    @bar_sprites = []
    @anim_sprites = []
    $hoverbox = Infobox.new(@viewport3)
    $infobox = Infobox.new(@viewport3)
    for i in $game_map.events.keys.sort
      sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
      @character_sprites.push(sprite)
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    # Make weather
    @weather = RPG::Weather.new(@viewport1)
    # Make picture sprites
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_screen.pictures[i]))
    end
    # Make timer sprite
    @timer_sprite = Sprite_Timer.new
    # Frame update
    update
  end
  
  def add_hex_to_port(sprite_class, port=3)
    vport = @viewport1
    case port
    when 2
      vport = @viewport2
    when 3
      vport = @viewport3
    end
    s = sprite_class.new(vport)
    @character_sprites.push(s)
    return s
  end
  
  def add_anim_to_port(sprite_class, port=3)
    vport = @viewport1
    case port
    when 2
      vport = @viewport2
    when 3
      vport = @viewport3
    end
    s = sprite_class.new(vport)
    @anim_sprites.push(s)
    return s
  end
  
  def add_bar_to_port(sprite_class, port=3)
    vport = @viewport1
    case port
    when 2
      vport = @viewport2
    when 3
      vport = @viewport3
    end
    s = sprite_class.new(vport)
    @bar_sprites.push(s)
    return s
  end
  
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    # Dispose of tilemap
    @tilemap.tileset.dispose
    for i in 0..6
      @tilemap.autotiles[i].dispose
    end
    @tilemap.dispose
    # Dispose of panorama plane
    @panorama.dispose
    # Dispose of fog plane
    @fog.dispose
    # Dispose of character sprites
    for sprite in @character_sprites
      sprite.dispose
    end
    for sprite in @anim_sprites
      sprite.dispose
    end
    for sprite in @bar_sprites
      sprite.dispose
    end
    # Dispose of weather
    @weather.dispose
    # Dispose of picture sprites
    for sprite in @picture_sprites
      sprite.dispose
    end
    # Dispose of timer sprite
    @timer_sprite.dispose
    # Dispose of viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # If panorama is different from current one
    if @panorama_name != $game_map.panorama_name or
       @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    # If fog is different than current fog
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    # Update tilemap
    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
    # Update panorama plane
    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8
    # Update fog plane
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    # Update character sprites
    for sprite in @character_sprites
      sprite.update
    end
    for sprite in @anim_sprites
      sprite.update
    end
    for sprite in @bar_sprites
      sprite.update
    end
    # Update weather graphic
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    # Update picture sprites
    for sprite in @picture_sprites
      sprite.update
    end
    # Update timer sprite
    @timer_sprite.update
    # Set screen color tone and shake position
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # Set screen flash color
    @viewport3.color = $game_screen.flash_color
    # Update viewports
    @viewport1.update
    @viewport3.update
  end
end
