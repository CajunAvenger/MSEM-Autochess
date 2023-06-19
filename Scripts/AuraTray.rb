class AuraTray
  attr_accessor :owner
  attr_accessor :sprite
  
  def initialize(owner)
    @owner = owner
    @sprite = new_hex_sprite
    @sprite.z = 6000
    if @owner.id == 1
      @sprite.bitmap = RPG::Cache.icon("aura_box.png")
      @sprite.x = 740
      @sprite.y = 620
      @sprite1 = new_hex_sprite
      @sprite1.x = 745
      @sprite1.y = 625
      @sprite2 = new_hex_sprite
      @sprite2.x = 793
      @sprite2.y = 625
      @sprite3 = new_hex_sprite
      @sprite3.x = 841
      @sprite3.y = 625
      
      if @owner.auras[0]
        @sprite1.bitmap = RPG::Cache.icon("AuraTiny/"+@owner.auras[0].sprite+".png")
      else
        @sprite1.visible = false
      end
      
      if @owner.auras[1]
        @sprite2.bitmap = RPG::Cache.icon("AuraTiny/"+@owner.auras[1].sprite+".png")
      else
        @sprite2.visible = false
      end
      
      if @owner.auras[2]
        @sprite3.bitmap = RPG::Cache.icon("AuraTiny/"+@owner.auras[2].sprite+".png")
      else
        @sprite3.visible = false
      end
      
    else
      @sprite.bitmap = RPG::Cache.icon("aura_box_2.png")
      @sprite.x = 94
      @sprite.y = 123
      @sprite1 = new_hex_sprite
      @sprite1.x = 94
      @sprite1.y = 128
      @sprite2 = new_hex_sprite
      @sprite2.x = 94
      @sprite2.y = 176
      @sprite3 = new_hex_sprite
      @sprite3.x = 94
      @sprite3.y = 224
    end
    @sprite1.z = 6001
    @sprite2.z = 6001
    @sprite3.z = 6001
  end
  
  def update
    return unless @owner
    if !@sprite1.visible && @owner.auras.length > 0
      @sprite1.bitmap = RPG::Cache.icon("AuraTiny/"+@owner.auras[0].sprite+".png")
      @sprite1.visible = true
    end
    if !@sprite2.visible && @owner.auras.length > 1
      @sprite2.bitmap = RPG::Cache.icon("AuraTiny/"+@owner.auras[1].sprite+".png")
      @sprite2.visible = true
    end
    if !@sprite3.visible && @owner.auras.length > 2
      @sprite3.bitmap = RPG::Cache.icon("AuraTiny/"+@owner.auras[2].sprite+".png")
      @sprite3.visible = true
    end
  end
  
  def aura_from_mouse(x, y)
    y_min = @sprite.y
    y_max = @sprite.y+@sprite.bitmap.height
    x_min = @sprite.x
    x_max = @sprite.x+@sprite.bitmap.width
    return nil unless y.between?(y_min, y_max)
    return nil unless x.between?(x_min, x_max)
    if x_max-x_min > y_max-y_min
      # my tray
      ind = (x-x_min-5) / 48
      return nil if ind < 0
      return @owner.auras[ind]
    else
      # opp tray
      ind = (y-y_min-5) / 48
      return nil if ind < 0
      return @owner.auras[ind]
    end
  end
end

$my_auras = nil
$your_auras = nil