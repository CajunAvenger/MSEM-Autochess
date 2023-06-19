$invis = Color.new(0, 0, 0, 0)
$white = Color.new(255, 255, 255)
$ally_life = Color.new(50, 155, 40)
$ally_life_cb = Color.new(5, 45, 20)
$enemy_life = Color.new(215, 20, 20)
$enemy_life_cb = Color.new(70, 25, 60)
$mana_building = Color.new(55, 40, 155)
$mana_building_cb = Color.new(55, 80, 100)
$mana_max = Color.new(85, 215, 200)
$gold_bar = Color.new(190, 160, 40)
$shield_color = Color.new(50, 100, 40)
$enemy_shield = Color.new(155, 20, 20)
class LifeBar < RPG::Sprite
  
  def initialize(viewport)
    super
    @l_cache = -1
    @invul = false
    @shield = 0
    self.z = 6000
    self.bitmap = Bitmap.new("Graphics/Icons/empty.png")
  end

  def set_unit(unit)
    @unit = unit
    @main_sprite = unit.sprite
  end
  
  def update
    #super
    return unless @unit
    return if @unit.sprite.disposed?
    
    self.x = @unit.sprite.x
    self.y = @unit.sprite.y+14
    self.z = @unit.sprite.z
    self.opacity = @unit.sprite.opacity
  end
  
  def update_bm
    max_life = @unit.get_value(:MAX_LIFE)
    life_percent = (max_life - @unit.current_damage).to_f / max_life
    life_pixels = (life_percent * 32).round()
    life_pixels = 0 if life_pixels < 0
    life_pixels = 1 if life_pixels == 0 && life_percent > 0
    life_pixels = 32 if life_pixels > 32
    invul_check = @unit.impacts.include?(:INVULNERABLE)
    shield_check = @unit.get_value(:SHIELD)
    if life_pixels != @l_cache || @invul != invul_check || @shield != shield_check
      @invul = invul_check
      @shield = shield_check
      @l_cache = life_pixels
      bar_color = $ally_life
      bar_color = $enemy_life if @unit.owner.id == 2
      bar_color = $gold_bar if @invul
      self.bitmap.fill_rect(1, 1, 5, 32, $invis)
      self.bitmap.fill_rect(1, 33-life_pixels, 5, life_pixels, bar_color)
      
      if @shield > 0
        sc = $shield_color
        sc = $enemy_shield if bar_color == $enemy_life
        s_pix = (@shield/max_life*32).round().cap(32)
        self.bitmap.fill_rect(0, 33-s_pix, 3, s_pix, sc)
      end
    end
    update
  end
  
end

class ManaBar < RPG::Sprite

  def initialize(viewport)
    super
    @m_cache = -1
    self.z = 6000
    self.bitmap = Bitmap.new("Graphics/Icons/empty.png")
  end

  def set_unit(unit)
    @unit = unit
    @main_sprite = unit.sprite
  end
  
  def update
    #super
    return unless @unit
    return if @unit.sprite.disposed?
    
    self.x = @unit.sprite.x+57
    self.y = @unit.sprite.y+14
    self.z = @unit.sprite.z
    self.opacity = @unit.sprite.opacity
  end
  
  def update_bm
    max = @unit.ability_cost
    max = -1*max if max < -1
    max = 10000 unless max > 1
    mana_percent = @unit.mana.to_f / max
    mana_pixels = (mana_percent * 32).floor()
    mana_pixels = 0 if mana_pixels < 0
    mana_pixels = 32 if mana_pixels > 32
    if mana_pixels != @m_cache
      @m_cache = mana_pixels
      bar_color = $mana_building
      bar_color = $mana_max if mana_percent > 1
      self.bitmap.fill_rect(1, 1, 5, 32, Color.new(0, 0, 0, 0))
      self.bitmap.fill_rect(1, 33-mana_pixels, 5, mana_pixels, bar_color)
    end
    update
  end
  
end

class NumSprite < RPG::Sprite
  def set_val(num)
    return if num < 0
    num = num.to_i.to_s
    self.bitmap = RPG::Cache.icon("Numbers/"+num+".png")
    update
  end
end

class TimerBar < RPG::Sprite
  attr_accessor :max_time
  attr_accessor :timer
  
  def set_time(max_frames)
    @max_frames = max_frames
    @max_pix = 480
    @spender = @max_frames.to_f / @max_pix
    @clock = @max_frames / $frames_per_second
    @timer = 0
    @tens = (@clock/10).floor()
    @ones = @clock - 10*@tens
    self.bitmap = Bitmap.new("Graphics/Icons/countdown_bar.png")
    self.x = 128
    self.y = 0
    @number_tens = $scene.spriteset.add_bar_to_port(NumSprite)
    @number_tens.set_val(@tens)
    @number_tens.x = 156
    @number_tens.y = 4
    @number_ones = $scene.spriteset.add_bar_to_port(NumSprite)
    @number_ones.set_val(@ones)
    @number_ones.x = 176
    @number_ones.y = 4
  end
  
  def update
    @timer += 1
    spent_pixels = (@timer/@spender).floor.cap(@max_pix)
    if spent_pixels > 0
      self.bitmap.fill_rect(94, 2, spent_pixels, 28, $invis)
    end
    on_clock = ((@max_frames - @timer).to_f / $frames_per_second).ceil
    if on_clock != @clock
      @clock = on_clock
      @ones -= 1
      if @ones < 0
        @ones = 9
        @tens -= 1
        @number_tens.set_val(@tens)
        @number_tens.update
      end
      @number_ones.set_val(@ones)
      @number_ones.update
    end
  end
end