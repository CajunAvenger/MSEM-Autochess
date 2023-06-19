class Storefront < Emitter
  attr_accessor :player         # the player this storefront belongs to
  attr_accessor :bumper         # whenever we roll, add this to our level
  attr_accessor :next_bumper    # next time we roll, add this to our level
  attr_accessor :locked         # is the store locked?
  attr_accessor :stock          # current items on offer
  attr_accessor :store_counter  # number of times shop has rerolled this round
  attr_accessor :round_tax      # extra cost for units this round
  attr_reader :pool             # the central pool
  
    X_start = 800
    Y_start = 138
    Main_drop = 64+8
    Syn_drop = 8
    Syn_off = 4
    B_width = 64
    Syn_width = 48
    Nub_height = 32
    Nub_width = 56
    P_drop = 12
    
    Sell_ar = [
      [],
      [0, 1, 2, 3, 4, 5],
      [0, 3, 5, 8, 11, 14],
      [0, 9, 17, 26, 35, 44]
    ]
  
  def initialize(player, pool)
    @listening_to_me = {}
    @my_listener_cache = []
    @player = player
    @pool = pool
    @next_bumper = 0
    @bumper = 0
    @locked = false
    init_sprites
    @stock = []
    @store_counter = 0
    @round_tax = 0
    @free_freshes = 0
    @round_freefresh = false
    reroll
  end
  
  # place the sprites but make them invisible
  def init_sprites
    @face_sprites = []
    @syn_sprites = []
    @cost_sprites = []
    @glows = []
    for i in 0..4
      face_spr = new_hex_sprite
      face_spr.visible = false
      face_spr.x = X_start
      face_spr.y = Y_start + Main_drop*i
      face_spr.z = 6000
      @syn_sprites.push([])
      for x in 0..2
        syn_spr = new_hex_sprite
        syn_spr.visible = false
        syn_spr.x = X_start + B_width + Syn_off*(x+1) + (Syn_width*x)
        syn_spr.y = Y_start + Syn_drop + Main_drop*i
        syn_spr.z = 6000
        @syn_sprites[@face_sprites.length].push(syn_spr)
      end
      @face_sprites.push(face_spr)
      cost_spr = new_hex_sprite
      cost_spr.x = X_start - B_width + 4
      cost_spr.y = Y_start + Main_drop*i + 16
      cost_spr.z = 6000
      @cost_sprites.push(cost_spr)
    end
    @gold_sprite = new_hex_sprite
    @gold_sprite.x = X_start - B_width + 4
    @gold_sprite.y = Y_start + 5*Main_drop
    @gold_sprite.z = 6000
    update_gold
    ug = Proc.new do |listen, amount|
      listen.subscriber.update_gold
    end
    gen_subscription_to(@player, :GainedGold, ug)
    
    @refresh_sprite = new_hex_sprite
    @refresh_sprite.bitmap = Bitmap.new("Graphics/icons/refresh_gold.png")
    @refresh_sprite.holder = "gold"
    @refresh_sprite.bitmap.font.name = "Fontin"
    @refresh_sprite.bitmap.font.size = 20
    @refresh_sprite.bitmap.font.color.set(255,255,255)
    @refresh_sprite.bitmap.draw_text(42, 42, 32, 20, "2")
    @refresh_sprite.x = X_start
    @refresh_sprite.y = Y_start + 5*Main_drop
    
    @xp_sprite = new_hex_sprite
    @xp_sprite.bitmap = Bitmap.new("Graphics/icons/xp_gold.png")
    @xp_sprite.holder = "gold"
    @xp_sprite.bitmap.font.name = "Fontin"
    @xp_sprite.bitmap.font.size = 20
    @xp_sprite.bitmap.font.color.set(255,255,255)
    @xp_sprite.bitmap.draw_text(42, 42, 32, 20, "4")
    @xp_sprite.x = X_start + B_width + Syn_off
    @xp_sprite.y = Y_start + 5*Main_drop
    @xp_sprite.opacity = 0
    
    @lock_sprite = new_hex_sprite
    @lock_sprite.x = X_start + 2*B_width + 2*Syn_off
    @lock_sprite.y = Y_start + 5*Main_drop
    unlock
    
    @life_sprite = new_hex_sprite
    @life_sprite.x = X_start - B_width + Syn_off
    @life_sprite.y = Y_start + 6*Main_drop + P_drop
    @life_sprite.z = 6000
    update_life
    
    @level_sprite = new_hex_sprite
    @level_sprite.x = X_start - B_width + 2*Syn_off + Nub_width
    @level_sprite.y = Y_start + 6*Main_drop + P_drop
    @level_sprite.z = 6000
    update_level
    
    @streak_sprite = new_hex_sprite
    @streak_sprite.x = X_start - B_width + 3*Syn_off + 2*Nub_width
    @streak_sprite.y = Y_start + 6*Main_drop + P_drop
    @streak_sprite.z = 6000
    update_streak
    
    zweil = new_hex_sprite
    zweil.x = X_start + 48
    zweil.y = 0
    zweil.z = 6000
    zweil.bitmap = RPG::Cache.icon("zweil.png")
    
    @sell_sprite = new_hex_sprite
    @sell_sprite.x = X_start - 64
    @sell_sprite.y = 0
    @sell_sprite.z = 7000
    @sell_sprite.visible = false
  end
  
  def unlock
    @locked = false
    @lock_sprite.bitmap = RPG::Cache.icon("unlocked.png")
  end
  
  def lock
    @locked = true
    @lock_sprite.bitmap = RPG::Cache.icon("locked.png")
  end
  
  def toggle_lock
    if @locked
      unlock
    else
      lock
    end
  end
  
  def update_gold
    @gold_sprite.bitmap = Bitmap.new("Graphics/Icons/gold_reserve.png")
    @gold_sprite.bitmap.font.name = "Fontin"
    @gold_sprite.bitmap.font.size = 25
    @gold_sprite.bitmap.font.color.set(255,255,255)
    @gold_sprite.bitmap.draw_text(0, 38, 56, 25, @player.gold.to_s, 1)
  end
  
  def update_life
    @life_sprite.bitmap = Bitmap.new("Graphics/Icons/life_banner.png")
    @life_sprite.bitmap.font.name = "Fontin"
    @life_sprite.bitmap.font.size = 20
    @life_sprite.bitmap.font.color.set(255,255,255)
    @life_sprite.bitmap.draw_text(28, 6, 32, 20, @player.life.to_s)
  end
  
  def update_level
    if @player.level == 2 && @xp_sprite.opacity == 0
      @xp_sprite.add_fade_to(255, 0.4*$frames_per_second)
    end
    text = @player.level.to_s + @player.xp.to_s
    if text != @cached_text
      @cached_text = text
      xp_to_level = $Level_xp[@player.level] || 0
      xp_per = 0
      xp_per = @player.xp * 100 / xp_to_level if xp_to_level > 0
      @level_sprite.bitmap = Bitmap.new("Graphics/Icons/level.png")
      @level_sprite.bitmap.font.name = "Fontin"
      @level_sprite.bitmap.font.size = 14
      @level_sprite.bitmap.font.color.set(255,255,255)
      @level_sprite.bitmap.draw_text(5, 10, 32, 20, @player.xp.to_s + "/" + xp_to_level.to_s)
      @level_sprite.bitmap.font.name = "Fontin"
      @level_sprite.bitmap.font.size = 32
      @level_sprite.bitmap.draw_text(38, -3, 40, 32, @player.level.to_s)
      @level_sprite.bitmap.fill_rect(3, 27, xp_per/2, 2, $white)
    end
  end
  
  def update_streak
    if @player.streak == 0
      @streak_sprite.bitmap = Bitmap.new("Graphics/Icons/no_streak.png")
    elsif @player.streak > 0
      @streak_sprite.bitmap = Bitmap.new("Graphics/Icons/win_streak.png")
    else
      @streak_sprite.bitmap = Bitmap.new("Graphics/Icons/lose_streak.png")
    end
    @streak_sprite.bitmap.font.name = "Fontin"
    @streak_sprite.bitmap.font.size = 20
    @streak_sprite.bitmap.font.color.set(255,255,255)
    @streak_sprite.bitmap.draw_text(36, 5, 32, 20, @player.streak.abs().to_s)
  end
  
  def info_from_pos(x, y)
    x_rcn = x - X_start
    y_rcn = y - Y_start
    y_per = y_rcn % Main_drop
    row_ind = (y_rcn / Main_drop).floor
    # below our last
    if !row_ind.between?(0, @stock.length-1)
      # top or bottom bits
      case y_rcn
      when -128..0
        # zweil
      when (5*Main_drop)..(5*Main_drop + B_width)
        # gold, refresh, xp, lock
        case x_rcn
        when (-B_width + Syn_off)..(-B_width + Syn_off + Nub_width)
          return {:kind => :gold}
        when 0..64
          return {:kind => :refresh}
        when (B_width + Syn_off)..(B_width + Syn_off + B_width)
          return {:kind => :xp} unless @player.level == 1
        when (2*B_width + 2*Syn_off)..(2*B_width + 2*Syn_off + B_width/2)
          return {:kind => :lock} unless y_rcn > 5*Main_drop + B_width/2
        end
      when (6*Main_drop + P_drop)..(6*Main_drop + P_drop + Nub_height)
        # life, streak, level
        case x_rcn
        when  (-B_width - Syn_off)..(-B_width - Syn_off + Nub_width)
          return {:kind => :life}
        when  (Nub_width+Syn_off)..(2*Nub_width+Syn_off)
          return {:kind => :streak}
        end
      end
      return nil
    end
    col_ind = nil
    # check which column we're in
    case x_rcn
    when 0..B_width
      col_ind = 0
    when (B_width+1*Syn_off+0*Syn_width)..(B_width+1*Syn_off+1*Syn_width)
      col_ind = 1
    when (B_width+2*Syn_off+1*Syn_width)..(B_width+2*Syn_off+2*Syn_width)
      col_ind = 2
    when (B_width+3*Syn_off+2*Syn_width)..(B_width+3*Syn_off+3*Syn_width)
      col_ind = 3
    end
    # past our last
    return nil if col_ind == nil
    case col_ind
    when 0
      # battler
      # check if its visible
      return nil if y_per > B_width
      return nil if @face_sprites[row_ind].visible == false
      # kind, sprite, unit, index
      return {
        :kind => :unit,
        :sprite => @face_sprites[row_ind],
        :unit_class => @stock[row_ind],
        :store_row => row_ind
      }
    else
      # syn
      syn_ind = col_ind - 1
      # check if its visible
      return nil unless y_per.between?(Syn_drop, Syn_drop+Syn_width)
      return nil if @syn_sprites[row_ind][syn_ind].visible == false
      # kind, sprite, syn_handler, walker name, index1, index2
      syn_sym = @syn_sprites[row_ind][syn_ind].holder
      syn_hand = @player.synergy_handlers[syn_sym]
      w_name = @face_sprites[row_ind].holder.get_base_stats[:name]
      return {
        :kind => :syn,
        :sprite => @syn_sprites[row_ind][syn_ind],
        :handler => syn_hand,
        :unit_name => w_name,
        :store_row => row_ind,
        :syn_row => syn_ind
      }
    end
  end
  
  # update the slot sprites
  def update_sprites
    update_gold
    update_refresh
    update_xp
    tiers = @player.star_up_tiers
    for g in @glows
      g.dispose
    end
    for s in 0..(@face_sprites.length-1)
      face_spr = @face_sprites[s]
      syn_sprs = @syn_sprites[s]
      cost_spr = @cost_sprites[s]
      walker = @stock[s]
      if !walker
        # walker sold, hide the sprite
        face_spr.visible = false
        for sp in syn_sprs
          sp.visible = false
        end
        cost_spr.visible = false
      else
        bst = walker.get_base_stats
        w_name = bst[:name]
        st_id = w_name + "1"
        st_id2 = w_name + "2"
        w_synergies = bst[:synergy]
        # update the face and synergy sprites
        face_spr.bitmap = walker.shop_sprite
        face_spr.holder = walker
        face_spr.visible = true
        for x in 0..syn_sprs.length-1
          syn = w_synergies[x]
          spr = syn_sprs[x]
          if !syn
            spr.visible = false
          else
            syn_handler = @player.synergy_handlers[syn]
            ms = syn_handler.sprite
            lv = syn_handler.test_level(w_name)
            bm = "Synergy/"+ms+"_"+lv.to_s+".png"
            spr.visible = true
            spr.bitmap = RPG::Cache.icon(bm)
            spr.holder = syn
          end
        end
        # update the cost sprite
        pay_type = "gold"
        cost = bst[:cost] + @round_tax
        if (@player.blood_units & bst[:synergy]).length > 0
          pay_type = "blood"
        end
        if !cost_spr.holder || cost_spr.holder[0] != cost.to_s || cost_spr.holder[1] != pay_type
          cost_spr.holder = [cost.to_s, pay_type]
          cost_spr.bitmap = Bitmap.new("Graphics/icons/"+pay_type+"_price.png")
          cost_spr.bitmap.font.name = "Fontin"
          cost_spr.bitmap.font.size = 20
          cost_spr.bitmap.font.color.set(255,255,255)
          cost_spr.bitmap.draw_text(42, 6, 32, 20, cost_spr.holder[0])
        end
        cost_spr.visible = true
        # update the glowing sprites for upgradeables
        bm = nil
        if tiers.include?(st_id2) && tiers.include?(st_id)
         # if we have two 2 stars and two 1 stars, use gold
          bm = "silver"
          bm = "light" if tiers[st_id2].length == 2 && tiers[st_id].length == 2
        elsif tiers.include?(st_id2) || tiers.include?(st_id)
          bm = "silver"
        end
        if bm
          glo = new_hex_sprite
          glo.bitmap = RPG::Cache.icon("Ability/Hexes/"+bm+".png")
          glo.x = face_spr.x
          glo.y = face_spr.y
          glo.z = face_spr.z + 1
          glo.opacity = 0
          glo.add_fading(120, 20, 1.5*$frames_per_second)
          @glows.push(glo)
        end
      end
    end
  end

  def restock(amount)
    for i in 1..amount
      break if @stock.length >= 5
      @stock.push(@pool.roll_unit(@player.level+@bumper))
    end
    update_sprites
  end
  
  def reroll
    return if @locked
    @store_counter += 1
    # if there's something on the mouse, drop it first
    if Mouse.holding?.is_a?(Sprite_Chess)
      prev_info = Mouse.holding?.holder
      prev_info[:sprite].opacity = 255
      Mouse.holding?.dispose
      Mouse.drop
    end
    lv = @player.level + @bumper
    if @next_bumper > 0
      lv += @next_bumper
      @next_bumper = 0
    end
    @stock = @pool.reroll(self, lv)
    update_sprites
  end
  
  def buy(ind, placer=nil)
    cn = @stock[ind]
    return unless cn
    bst = cn.get_base_stats
    cost = bst[:cost] + @round_tax
    type = @cost_sprites[ind].holder[1]
    if type == "gold"
      return if @player.gold < cost
      unit = cn.new
      if @player.give_unit(unit, placer)
        @player.spend_gold(cost)
        @stock.delete_at(ind)
        update_sprites
      end
      @player.emit(:UnitBought, unit)
    elsif type == "blood"
      return if @player.life < cost
      unit = cn.new
      if @player.give_unit(unit, placer)
        @player.lose_life(cost)
        @stock.delete_at(ind)
        update_sprites
      end
      @player.emit(:UnitBought, unit)

    end
  end
  
  def blood_refresh
    if @refresh_sprite.holder == "blood"
      @refresh_sprite.holder = "gold"
    else
      @refresh_sprite.holder = "blood"
    end
    update_refresh
  end
  
  def update_refresh
    if @refresh_sprite.holder == "blood"
      @refresh_sprite.bitmap = Bitmap.new("Graphics/icons/refresh_blood.png")
    else
      @refresh_sprite.bitmap = Bitmap.new("Graphics/icons/refresh_gold.png")
    end
    @refresh_sprite.bitmap.font.name = "Fontin"
    @refresh_sprite.bitmap.font.size = 20
    @refresh_sprite.bitmap.font.color.set(255,255,255)
    val = 2 + @round_tax
    val = 0 if @free_freshes > 0
    @refresh_sprite.bitmap.draw_text(42, 42, 32, 20, val.to_s)
  end
    
  def blood_xp
    if @xp_sprite.holder == "blood"
      @xp_sprite.holder = "gold"
    else
      @xp_sprite.holder = "blood"
    end
  end
  
  def update_xp
    if @xp_sprite.holder == "blood"
      @xp_sprite.bitmap = Bitmap.new("Graphics/icons/xp_blood.png")
    else
      @xp_sprite.bitmap = Bitmap.new("Graphics/icons/xp_gold.png")
    end
    @xp_sprite.bitmap.font.name = "Fontin"
    @xp_sprite.bitmap.font.size = 20
    @xp_sprite.bitmap.font.color.set(255,255,255)
    val = 4 + @round_tax
    @xp_sprite.bitmap.draw_text(42, 42, 32, 20, val.to_s)    
  end
  
  def buy_xp
    cost = 4 + @round_tax
    if @xp_sprite.holder == "gold" && @player.gold >= cost
      @player.spend_gold(cost)
      @player.gain_xp(4)
    elsif @xp_sprite.holder == "blood" && @player.life >= cost
      @player.lose_life(cost)
      @player.gain_xp(4)
    end
  end
  
  def buy_reroll
    unlock
    cost = 2 + @round_tax
    if @free_freshes > 0
      cost = 0
      @free_freshes -= 1
      @round_freefresh = false if @round_freefresh
    end
    if @refresh_sprite.holder == "gold" && @player.gold >= cost
      @player.spend_gold(cost)
    elsif @refresh_sprite.holder == "blood" && @player.life >= cost
      @player.lose_life(cost)
    else
      return
    end
    reroll
    @player.refresh_counter += 1
  end
  
  def sell(unit)
    sell_val = Sell_ar[unit.level][unit.cost]
    @player.give_gold(sell_val, :selling)
    @player.remove_unit(unit)
    # give the unit back to the pool
    restock_name = $planeswalkers[:name_map][unit.name]
    @pool.restock(restock_name)
    # update the gold sprite
    update_gold
    if @player.empowered.include?(:fallback) && unit.level > 1
      @free_freshes += 3
      update_refresh
    end
    @player.emit(:UnitSold, unit)
  end
  
  def sell_artifact(artifact)
    sell_val = artifact.get_base_stats[:cost]
    @player.give_gold(sell_val, :selling_artifact)
  end
  
  def update_sell_sprite
    holding_sellable = Mouse.holding?.is_a?(Unit) || (@player.sell_artifacts && Mouse.holding?.is_a?(Sprite_Artifact))
    if @sell_sprite.visible && !holding_sellable
      # hide the sprite if we're not moving a unit or sellable artifact
      @sell_sprite.visible = false
    elsif !@sell_sprite.visible && holding_sellable
      sell_val = 0
      if Mouse.holding?.is_a?(Sprite_Artifact)
        sell_val = Mouse.holding?.artifact.get_base_stats[:cost]
      else
        sell_val = Sell_ar[Mouse.holding?.level][Mouse.holding?.cost]
      end
      text = "Sell for " + sell_val.to_s + "G?"
      # update the sprite if we're moving a unit
      @sell_sprite.bitmap = Bitmap.new("Graphics/Icons/sell.png")
      @sell_sprite.bitmap.font.name = "Fontin"
      @sell_sprite.bitmap.font.size = 17
      @sell_sprite.bitmap.font.color.set(0,0,0)
      @sell_sprite.bitmap.draw_text(16, 36, 94, 20, text, 1)
      @sell_sprite.visible = true
    else
      @sell_sprite.visible = false
    end
  end
  
  def round_up
    console.log("round up")
    console.log(@round_tax)
    @store_counter = 0
    if @player.empowered.include?(:amber) && !@round_freefresh
      @free_freshes += 1
      @round_freefresh = true
    end
    reroll
    update_sprites if @locked
  end
  
end