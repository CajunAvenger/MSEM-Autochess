class Sprite_Artifact < Sprite_Scheduler
  attr_accessor :artifact
  attr_accessor :b1
  attr_accessor :b2
  attr_accessor :off_x
  attr_accessor :equip_only
  
  def update
    if !@artifact
      # hide abandoned sprites
      self.vis(false)
    elsif !@artifact.wielder
      # show sprites that aren't attached to anything
      if @equip_only
        self.vis(false)
      else
        self.vis(true)
      end
    elsif Mouse.holding?.is_a?(Sprite_Artifact) || Mouse.holding? == @artifact.wielder
      self.vis(true)
    elsif Input.press?(Input::SHIFT)
      # show sprites when we're holding shift
      self.vis(true)
    elsif Mouse.hovering_over?(@artifact.wielder) || Mouse.hovering_on?(@artifact)
      # show sprites when we're hovering on them or their wielder
      self.vis(true)
    else
      # otherwise hide
      self.vis(false)
    end
    if @artifact && @artifact.wielder && @artifact.wielder.sprite
      self.y = @artifact.wielder.sprite.y + 27
      self.x = @artifact.wielder.sprite.x + 21*@artifact.wielder.artifacts.index(@artifact)
      self.x += @off_x if @off_x
    end
    super
  end
  
  def cb_bitmap
    return unless @b1
    if $colorblind
      self.bitmap = $backdrop_bitmaps[:colorblind][b1][b2]
    else
      self.bitmap = $backdrop_bitmaps[:base][b1][b2]
    end
  end
  
end

def new_artifact_sprite(cl=Sprite_Artifact)
  sp = $scene.spriteset.add_hex_to_port(cl)
  $artifact_sprites.push(sp)
  return sp
end