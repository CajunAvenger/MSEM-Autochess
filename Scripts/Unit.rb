# Initialize the values of a unit
class Unit < Emitter
  attr_reader :name             # string name of this unit
  attr_reader :cost             # base cost of this unit
  attr_accessor :synergies      # array of synergy symbols
  attr_accessor :leech_synergies# array of synergy symbols this is leeching
  attr_accessor :tink_synergies # array of synergy symbols artifacts are giving this
  attr_reader :range            # range level array of this unit
  attr_reader :power            # power level array of this unit
  attr_reader :multistrike      # multistrike chance level array of this unit
  attr_reader :haste            # haste level array of this unit
  attr_reader :mana_amp         # mana amp level array of this unit
  attr_reader :archive          # archive array of this unit
  attr_reader :toughness        # toughness level array of this unit
  attr_reader :ward             # ward level array of this unit
  attr_reader :max_life         # max life level array of this unit
  attr_accessor :ability_cost   # current ability cost, normally 100
  attr_reader :cached_cost      # ability cost that's been modified by ward targets

  attr_reader :id               # symbol ID
  attr_reader :id_number        # ID number
  attr_accessor :owner          # owner obj
  
  attr_accessor :current_damage # current damage on this unit
  attr_accessor :mana_cooldown  # cooldown for gaining mana after using an ability
  attr_accessor :aggro          # current unit this is aggroing
  attr_accessor :mana           # current mana of this unit
  attr_accessor :level          # current mana of this unit
  attr_accessor :current_hex    # current hex of this unit
  attr_accessor :starting_hex   # starting hex to return to on round end
  attr_accessor :dead           # is this unit dead?
  attr_accessor :ticker         # counter that determines when unit attacks
  attr_reader :sprite           # unit's current sprite
  attr_accessor :stunsprite     # unit's stunsprite holder
  attr_accessor :temp_amp       # mana_amp that is erased the next time ability resolves

  attr_reader :buffs            # buffs on this unit
  attr_reader :artifacts        # artifacts this is wielding
  attr_reader :impacts          # impacts on this unit
  attr_reader :immunities       # keys this unit is immune to
  attr_reader :cloaked          # unit is cloaked?
  attr_accessor :rooted         # unit is rooted?
  attr_accessor :move           # bonus movement from artifacts
  attr_accessor :temp           # unit is temporary?
  attr_accessor :transit        # unit is moving rather than attacking?
  attr_accessor :deployed       # unit is deployed?
  attr_accessor :bonus_loss_damage  # bonus damage this unit deals if it survives combat
  attr_accessor :empowered      # special keys from auras
  
  attr_accessor :damage_dealt   # cumulative damage dealt
  attr_accessor :damage_taken   # cumulative damage taken
  attr_accessor :damage_healed  # cumulative damage healed

  def self.get_base_stats
    return {
      :name       => "Unnamed",
      :display    => "Unnamed, the Unit",
      :cost       => 1,
      :synergy    => [],
      :range      => [1, 1, 1],
      :power      => [10, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [10, 20, 40],
      :mana_amp   => [10, 20, 40],
      :archive    => [10, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [10, 20, 40],
      :slow_start => 0,
      :ability_cost => 100,
      :mana_cooldown => 1.0
    }
  end
  
  def get_base_stats
    return self.class.get_base_stats
  end
  
  def initialize(owner=nil, stars=1)
    @listening_to_me = {}
    @my_listener_cache = []
    @stacks = {}
    base_stats = get_base_stats()
    @level = stars
    @owner = owner
    @name = base_stats[:name]
    @displayname = base_stats[:display] || @name
    @cost = base_stats[:cost]
    @synergies = base_stats[:synergy]
    @leech_synergies = []
    @tink_synergies = []
    @path_cache = nil
    @empowered = []
    
    @range = base_stats[:range]
    @power = base_stats[:power]
    @multistrike = base_stats[:multi]
    @haste = base_stats[:haste]
    @mana_amp = base_stats[:mana_amp]
    @archive = base_stats[:archive]
    @toughness = base_stats[:toughness]
    @ward = base_stats[:ward]
    @range = [@range, @range, @range] unless @range.is_a?(Array)
    @power = [@power, @power, @power] unless @power.is_a?(Array)
    @multistrike = [@multistrike, @multistrike, @multistrike] unless @multistrike.is_a?(Array)
    @haste = [@haste, @haste, @haste] unless @haste.is_a?(Array)
    @mana_amp = [@mana_amp, @mana_amp, @mana_amp] unless @mana_amp.is_a?(Array)
    @archive = [@archive, @archive, @archive] unless @archive.is_a?(Array)
    @toughness = [@toughness, @toughness, @toughness] unless @toughness.is_a?(Array)
    @ward = [@ward, @ward, @ward] unless @ward.is_a?(Array)
    
    @max_life = base_stats[:life]
    @current_hex = nil
    
    @buffs = {}
    @artifacts = []
    @impacts = {}
    
    @immunities = []    

    @ability_cost = base_stats[:ability_cost] || 100
    @mana_cooldown = 0
    @current_damage = 0.0
    @mana = base_stats[:starting_mana] || 0.0
    @ticker = tps/get_value(:HASTE)
    if base_stats.include?(:slow_start)
      @ticker -= base_stats[:slow_start]
    end
    @cached_cost = nil
    @temp_amp = 0
    @id_number = get_unit_id()
    @id = @name + @id_number.to_s
    
    @damage_dealt = 0
    @damage_taken = 0
    @damage_healed = 0
    @aggro = nil
    @dead = false
    @transit = false
    @rooted = 0
    @move = 0
    @deployed = false
    @bonus_loss_damage = 0
  end
  
  include Enchantable
  
  def level_up
    @level += 1
    @sprite.bitmap = RPG::Cache.icon("Battler/" + @level.to_s + "/" + filename_clean(@name) + ".png")
    emit(:StarredUp)
  end
  
  def board_slots
    return 2 if @empowered.include?(:TwoSlots)
    return 0 unless self.is_a?(Planeswalker)
    return 1
  end
  
  def sprite_file(blank=false)
    lv = @level
    lv = 0 if blank
    lv = 3 if @level > 3
    "Battler/" + @level.to_s + "/" + filename_clean(@name) + ".png"
  end
  
  def self.shop_sprite
    name =  self.get_base_stats[:name].sub "'", ""
    return RPG::Cache.icon("Battler/1/" + name + ".png")
  end
  
  def filename_clean(str)
    return str.sub "'", ""
  end
  
  def place_sprite(sprite)
    sprite.bitmap = RPG::Cache.icon(sprite_file)
    if @current_hex
      sprite.x = @current_hex.pixel_x
      sprite.y = @current_hex.pixel_y
    else
      sprite.x = -100
      sprite.y = -100
    end
    sprite.z = 6000
    sprite.z += 1 if @synergies.include?(:AERIAL)
    @sprite = sprite
    
    @life_bar = $scene.spriteset.add_bar_to_port(LifeBar)
    @life_bar.set_unit(self)
    @life_bar.update_bm
    @mana_bar = $scene.spriteset.add_bar_to_port(ManaBar)
    @mana_bar.set_unit(self)
    @mana_bar.update_bm
    @sprite.subsprites.push(@life_bar)
    @sprite.subsprites.push(@mana_bar)
  end
  
  def update_life
    return unless @life_bar
    @life_bar.update_bm
  end
  
  def update_mana
    return unless @mana_bar
    @mana_bar.update_bm
  end
  
  def update_bars
    update_life
    update_mana
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/sword.png"
  end
  
  def six_sprite_file(attack_keys)
    return "Weapon/six.png"
  end
  
  def attack_anim_type
    return :standard
  end
  
  def build_attack_sprite(attack_keys)
    file = attack_sprite_file(attack_keys)
    file = six_sprite_file(attack_keys) if attack_keys.include?(:six_shot)
    return RPG::Cache.icon(file)
  end
  
  def stun
    # stun already ongoing
    if @stunsprite
      return unless @stunsprite.disposed?
    end
    @stunsprite = new_animation_sprite
    @stunsprite.add_stun_halo(self)
    emit(:Stunned)
  end
  
  def dir_to_tag(dir)
    case dir
    when :top
      return "_t"
    when :bottom
      return "_b"
    when :left
      return "_l"
    when :right
      return "_r"
    when :top_left
      return "_tl"
    when :top_right
      return "_tr"
    when :bottom_right
      return "_br"
    when :bottom_left
      return "_bl"
    else
      return ""
    end
  end
  
  def star_id
    return @name + @level.to_s
  end
  
  def has_infobox?
    return true
  end
  
  def write_to_infobox(infobox, extra=nil)
    text = ""
    text += @displayname
    m_mana = @cached_cost
    m_mana = @ability_cost unless m_mana

    vals = [
      get_value(:POWER).to_i.to_s,
      get_value(:MULTI).to_i.to_s,
      get_value(:HASTE).to_s,
      get_value(:MANA_AMP).to_i.to_s,
      get_value(:ARCHIVE).to_i.to_s,
      get_value(:RANGE).to_i.to_s,
      get_value(:TOUGHNESS).to_i.to_s,
      get_value(:WARD).to_i.to_s,
      @mana.cap(m_mana).to_i.to_s,
      m_mana.to_i.to_s,
      get_value(:LIFE).to_i.to_s,
      get_value(:MAX_LIFE).to_i.to_s
    ]
    for v in vals
      text += v
    end
    
    bm = "Graphics/Icons/unitbox/unit_" + @level.to_s
    bm += "_cb" if $colorblind
    bm += ".png"

    if text != infobox.cached_text
      infobox.cached_text = text
      infobox.submenu = self
      infobox.bitmap = Bitmap.new(bm)
      infobox.bitmap.font.name = "Fontin"
      infobox.bitmap.font.size = 20
      infobox.bitmap.font.color.set(255,255,255)
      infobox.bitmap.draw_text(16*(@level+1), 5, 160, 24, @displayname)
      
      infobox.bitmap.draw_text(200, 4, 40, 24, @cost.to_s)
      
      infobox.bitmap.draw_text(10, 38, 32, 24, vals[0], 1)
      infobox.bitmap.draw_text(88, 38, 32, 24, vals[1] + "%", 1)
      infobox.bitmap.draw_text(182, 38, 32, 24, vals[2], 1)
      
      infobox.bitmap.draw_text(10, 79, 32, 24, vals[3], 1)
      infobox.bitmap.draw_text(88, 79, 32, 24, vals[4], 1)
      infobox.bitmap.draw_text(182, 79, 32, 24, vals[5], 1)
      
      infobox.bitmap.draw_text(10, 121, 32, 24, vals[6], 1)
      infobox.bitmap.draw_text(88, 121, 32, 24, vals[7], 1)
      infobox.bitmap.draw_text(155, 121, 65, 24, vals[8] + "/" + vals[9], 1)
      
      infobox.bitmap.draw_text(145, 162, 75, 24, vals[10] + "/" + vals[11], 1)
      
      base_syn = get_base_stats[:synergy]
      x_start = 3
      r = Rect.new(0, 0, 48, 48)
      for id in base_syn
        bm = "Graphics/Icons/Synergy/"+@owner.synergy_handlers[id].sprite+".png"
        bm = Bitmap.new(bm)
        infobox.bitmap.blt(x_start, 149, bm, r)
        x_start += 45
      end
      
    end
  end
  
  def self.has_infobox?
    return true
  end
  
  def self.get_first(thing)
    return thing[0] if thing.is_a?(Array)
    return thing
  end
  
  def self.write_to_infobox(infobox, extra=nil)
    bst = get_base_stats
    name = bst[:name]
    name = bst[:display] if bst[:display]
    text = "" + name
    vals = [
      get_first(bst[:power]).to_s,
      get_first(bst[:multi]).to_s,
      get_first(bst[:haste]).to_s,
      get_first(bst[:mana_amp]).to_s,
      get_first(bst[:archive]).to_s,
      get_first(bst[:range]).to_s,
      get_first(bst[:toughness]).to_s,
      get_first(bst[:ward]).to_s,
      (bst[:starting_mana] || 0).to_s,
      (bst[:ability_cost] || 100).to_s,
      get_first(bst[:life]).to_s,
      get_first(bst[:life]).to_s
    ]
    for v in vals
      text += v
    end
    
    bm = "Graphics/Icons/unitbox/unit_1"
    bm += "_cb" if $colorblind
    bm += ".png"

    if text != infobox.cached_text
      infobox.cached_text = text
      infobox.submenu = self
      infobox.bitmap = Bitmap.new(bm)
      infobox.bitmap.font.name = "Fontin"
      infobox.bitmap.font.size = 18
      infobox.bitmap.font.color.set(255,255,255)
      
      infobox.bitmap.draw_text(32, 5, 160, 24, name)
      infobox.bitmap.draw_text(200, 4, 40, 24, bst[:cost].to_s)
      
      infobox.bitmap.draw_text(10, 38, 32, 24, vals[0], 1)
      infobox.bitmap.draw_text(88, 38, 32, 24, vals[1] + "%", 1)
      infobox.bitmap.draw_text(182, 38, 32, 24, vals[2], 1)
      
      infobox.bitmap.draw_text(10, 79, 32, 24, vals[3], 1)
      infobox.bitmap.draw_text(88, 79, 32, 24, vals[4], 1)
      infobox.bitmap.draw_text(182, 79, 32, 24, vals[5], 1)
      
      infobox.bitmap.draw_text(10, 121, 32, 24, vals[6], 1)
      infobox.bitmap.draw_text(88, 121, 32, 24, vals[7], 1)
      infobox.bitmap.draw_text(155, 121, 65, 24, vals[8] + "/" + vals[9], 1)
      
      infobox.bitmap.draw_text(145, 162, 75, 24, vals[10] + "/" + vals[11], 1)
      
      base_syn = get_base_stats[:synergy]
      x_start = 3
      r = Rect.new(0, 0, 48, 48)
      for id in base_syn
        bm = "Graphics/Icons/Synergy/"+$player.synergy_handlers[id].sprite+".png"
        bm = Bitmap.new(bm)
        infobox.bitmap.blt(x_start, 149, bm, r)
        x_start += 47
      end
      
    end
  end
  
  def self.get_submenu
    x, y = *Mouse.pos
    x_rcn = x - $infobox.x
    y_rcn = y = $infobox.y
    case y_rcn
    when 35..67
      return :power if x_rcn.between?(7, 71)
      return :multi if x_rcn.between?(80, 156)
      return :haste if x_rcn.between?(177, 241)
    when 76..108
      return :mana_amp if x_rcn.between?(7, 71)
      return :archive if x_rcn.between?(80, 156)
      return :range if x_rcn.between?(177, 241)
    when 117..149
      return :toughness if x_rcn.between?(7, 71)
      return :ward if x_rcn.between?(80, 156)
      return :mana if x_rcn.between?(160, 250)
    when 150..200
      syns = get_base_stats[:synergy]
      case x_rcn
      when 2..49
        return nil unless syns.length > 0
        return $player.synergy_handlers[syns[0]]
      when 50..97
        return nil unless syns.length > 1
        return $player.synergy_handlers[syns[1]]
      when 98..145
        return nil unless syns.length > 2
        return $player.synergy_handlers[syns[2]]
      end
    end
  end
  
  def get_submenu
    x, y = *Mouse.pos
    x_rcn = x - $infobox.x
    y_rcn = y - $infobox.y
    case y_rcn
    when 35..67
      return :power if x_rcn.between?(7, 71)
      return :multi if x_rcn.between?(80, 156)
      return :haste if x_rcn.between?(177, 241)
    when 76..108
      return :mana_amp if x_rcn.between?(7, 71)
      return :archive if x_rcn.between?(80, 156)
      return :range if x_rcn.between?(177, 241)
    when 117..149
      return :toughness if x_rcn.between?(7, 71)
      return :ward if x_rcn.between?(80, 156)
      return :mana if x_rcn.between?(160, 250)
    when 150..200
      syns = get_base_stats[:synergy]
      case x_rcn
      when 2..49
        return nil unless syns.length > 0
        return @owner.synergy_handlers[syns[0]]
      when 50..97
        return nil unless syns.length > 1
        return @owner.synergy_handlers[syns[1]]
      when 98..145
        return nil unless syns.length > 2
        return @owner.synergy_handlers[syns[2]]
      end
    end
    return nil
  end
  
=begin
  33% chance to drop loot per minion level
  last minion guaranteed to drop if none have
  
  60% Common Box
    contains 1-6 gold
  30% Uncommon Box
    34% chance of 4-9 gold
    33% chance of non-TinkTools component
    33% chance of level-rolled champion
  10% Rare Box
    25% chance of 7-11 gold
    25% chance of TinkTools
    25% chance of non-TinkTools completed artifact
    25% chance of two level-rolled champions
=end

  def loot_drop
    contents = nil
    chance_to_drop = @level*100/3
    if @owner.boxes_dropped < 1 && @owner.deployed.length == 1
      # guaranteed drop if this is the last unit and none have dropped
      chance_to_drop = 100
    end
    r1 = rand(100)
    if r1 < chance_to_drop
      @owner.boxes_dropped += 1
      r2 = rand(100)
      r3 = rand(100)
      case r2
      when 0..60
        # common box
        # 1-6 gold
        g = rand(6) + 1
        @owner.opponent.give_gold(g, :loot)
        contents = [g, :gold]
        loot = new_animation_sprite
        loot.bitmap = RPG::Cache.icon("loot.png")
        loot.z = 6100
        loot.center_on(@sprite)
        loot.y -= 10
        loot.add_translate(0, 10, 0.3*fps)
        loot.add_fade_to(0, 0.5*fps)
        loot.add_dispose
      when 61..90
        # uncommon box
        case r3
        when 0..33
          # 4-9 gold
          g = rand(5) + 5
          @owner.opponent.give_gold(g, :loot)
          contents = [g, :gold]
          loot = new_animation_sprite
          loot.bitmap = RPG::Cache.icon("loot.png")
          loot.z = 6100
          loot.center_on(@sprite)
          loot.y -= 10
          loot.add_translate(0, 10, 0.3*fps)
          loot.add_fade_to(0, 0.5*fps)
          loot.add_dispose
        when 34..66
          # random basic component
          ind = rand($artifacts[:component].length - $rare_components.length)
          arti = $artifacts[:component][ind].new(@current_hex)
          contents = [arti, :artifact]
        when 67..99
          # walker from the pool
          unit = $walker_pool.roll_unit(@owner.opponent.level).new
          @owner.opponent.give_unit(unit)
          contents = [unit, :unit]
          sp1 = new_animation_sprite
          sp1.bitmap = RPG::Cache.icon("sparkles.png")
          sp1.x = @sprite.x
          sp1.y = @sprite.y
          sp1.z = 6100
          sp1.opacity = 200
          sp1.add_move_to(unit.current_hex.pixel_x, unit.current_hex.pixel_y, 0.2*fps)
          sp1.add_dispose
        end
      when 90..99
        # rare box
        case r3
        when 0..24
          # 7-11 gold
          g = rand(5) + 7
          @owner.opponent.give_gold(g, :loot)
          contents = [g, :gold]
          loot = new_animation_sprite
          loot.bitmap = RPG::Cache.icon("loot.png")
          loot.z = 6100
          loot.center_on(@sprite)
          loot.y -= 10
          loot.add_translate(0, 10, 0.3*fps)
          loot.add_fade_to(0, 0.5*fps)
          loot.add_dispose
        when 25..49
          # a rare component
          arti = $rare_components[rand($rare_components.length)].new(@current_hex)
          contents = [arti, :artifact]
        when 50..74
          # a completed item
          arti = $artifacts[:completed][rand($artifacts[:completed].length)].new(@current_hex)
          contents = [arti, :artifact]
        when 75..99
          # two champions from the pool
          unit = $walker_pool.roll_unit(@owner.opponent.level).new
          @owner.opponent.give_unit(unit)
          unit2 = $walker_pool.roll_unit(@owner.opponent.level).new
          @owner.opponent.give_unit(unit2)
          contents = [unit, :unit, unit2]
          sp1 = new_animation_sprite
          sp1.bitmap = RPG::Cache.icon("sparkles.png")
          sp1.x = @current_hex.pixel_x
          sp1.y = @current_hex.pixel_y
          sp1.z = 6100
          sp1.add_move_to(unit.current_hex.pixel_x, unit.current_hex.pixel_y, 0.2*fps)
          sp1.add_dispose
          sp2 = new_animation_sprite
          sp2.bitmap = RPG::Cache.icon("sparkles.png")
          sp2.x = @current_hex.pixel_x
          sp2.y = @current_hex.pixel_y
          sp2.z = 6100
          sp2.add_move_to(unit2.current_hex.pixel_x, unit2.current_hex.pixel_y, 0.2*fps)
          sp2.add_dispose
        end
      end
    end
    @owner.opponent.emit(:Looted, contents)
  end
  
end