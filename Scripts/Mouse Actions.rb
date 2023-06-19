class Scene_Map
  
  def mouse_script
    # cache the section we're over
    section = Mouse.section
    # main info
    info = nil
    # labeled info
    hex = nil
    a_tray_info = nil
    a_sprite = nil
    store_info = nil
    syn_info = nil
    aur = nil
    # grab the hover info
    case section
    when :hexes
      info = $game_master.hex_from_mouse(*Mouse.pos)
      if !info
        Mouse.hover(:hexes)
      else
        hex = info
        if info.battler
          Mouse.hover(info.battler)
        else
          Mouse.hover(info)
        end
      end
    when :artifact
      # either position array or a sprite
      info = $artifact_tray.info_from_pos(*Mouse.pos)
      if info.is_a?(Array)
        a_tray_info = info
        Mouse.hover(:artifact)
      else
        a_sprite = info
        Mouse.hover(a_sprite)
      end
    when :store
      # hash of information from the store
      if $player && $player.storefront
        info = $player.storefront.info_from_pos(*Mouse.pos)
        store_info = info
        if !info
          Mouse.hover(:store)
        elsif info[:sprite]
          Mouse.hover(info[:sprite])
        else
          Mouse.hover(info[:kind])
        end
      end
    when :synergy
      info = $game_master.players[0].syn_tray.syn_from_mouse(*Mouse.pos)
      syn_info = info
      if syn_info
        Mouse.hover(syn_info)
      else
        Mouse.hover(:synergy)
      end
    when :auras
      info = $my_auras.aura_from_mouse(*Mouse.pos)
      info = $your_auras.aura_from_mouse(*Mouse.pos) unless info
      aur = info
      if info
        Mouse.hover(:auras)
      else
        Mouse.hover(aur)
      end
    end
    
    # use the info based on where we are
    if (Mouse.trigger?(0) || Mouse.release?(0) > 12) && Mouse.grid != nil
      # left click or left drag
      if !Mouse.holding?
        # picking something up
        if hex && hex.battler && hex.battler.owner == $player && hex.can_edit
          # pick up a Unit
          Mouse.hold(hex.battler)
          # leave @current_hex, we may need to put it back
          # may need to change this
          hex.battler = nil
        elsif a_sprite
          # pick up an Artifact
          Mouse.hold($artifact_tray.take(a_sprite))
        elsif store_info
          # clicking a store button
          case store_info[:kind]
          when :unit
            # picking up a shop item
            # fade out the shop sprite
            # create a copy hex sprite on the mouse
            # have the sprite hold the info and mouse hold the sprite
            store_info[:sprite].opacity = 100
            copy_spr = new_hex_sprite
            copy_spr.bitmap = store_info[:sprite].bitmap
            copy_spr.z = store_info[:sprite].z + 10
            copy_spr.holder = store_info
            copy_spr.on_mouse = true
            Mouse.hold(copy_spr)
          when :lock
            # toggle the lock
            $player.storefront.toggle_lock
          when :xp
            # buy xp
            $player.storefront.buy_xp
          when :refresh
            # buy reroll
            $player.storefront.buy_reroll
          end
        elsif section == :aura_scene
          $aura_scene.choose(*Mouse.pos)
        elsif section == :artifact_scene
          $artifact_scene.choose(*Mouse.pos)
        elsif section == :auras
          start_aura_scene(1)
        end
      elsif Mouse.holding?.is_a?(Unit)
        # putting down a Unit
        if hex && hex.start_player.id == 1 && hex.can_edit
          # we can put a unit here
          # check if we have enough slots
          psf = $player.board_slots_free
          psf += hex.battler.board_slots if hex.battler
          valid = psf >= Mouse.holding?.board_slots
          if valid
            if hex.battler
              # there's something here, switch them
              Mouse.holding?.current_hex.battler = hex.battler
              hex.battler.update_hex(Mouse.holding?.current_hex, true)
            end
            # there's nothing here, place it
            hex.battler = Mouse.holding?
            Mouse.holding?.update_hex(hex, true)
            Mouse.drop
          else
            # can't place this here, throw it back where it came from
            Mouse.drop(true)
          end
        elsif section == :store && Mouse.holding?.is_a?(Planeswalker)
          # selling a unit
          $player.storefront.sell(Mouse.holding?)
          Mouse.holding?.sprite.dispose
          Mouse.drop
        else
          # can't place this here, throw it back where it came from
          Mouse.drop(true)
        end
      elsif Mouse.holding?.is_a?(Sprite_Artifact)
        # putting down an artifact
        if hex && hex.battler && hex.battler.owner == $player && hex.can_edit
          # equipping an artifact
          given = hex.battler.give_artifact(Mouse.holding?.artifact)
          Mouse.drop(!given)
        elsif section == :store && $player.sell_artifacts
          # selling an artifact
          $player.storefront.sell_artifact(Mouse.holding?.artifact)
          Mouse.holding?.dispose
          Mouse.drop
        elsif a_sprite
          # switch with another artifact on the tray
          Mouse.hold($artifact_tray.swap(a_sprite, Mouse.holding?))
        elsif a_tray_info
          # place on an empty place in the tray
          $artifact_tray.place(Mouse.holding?, *a_tray_info)
          Mouse.drop
        else
          # some nonsense place, throw it back
          Mouse.drop(true)
        end
      elsif Mouse.holding?.is_a?(Sprite)
        # placing a Shop sprite somewhere
        # reset the original sprite, drop and dispose the clone
        prev_info = Mouse.holding?.holder
        prev_info[:sprite].opacity = 255
        Mouse.holding?.dispose
        Mouse.drop
        if hex && !hex.battler && hex.start_player == $player && hex.can_edit
          # placing this on a free hex of ours, buy it
          $player.storefront.buy(prev_info[:store_row], hex)
        elsif store_info && store_info[:store_row] == prev_info[:store_row]
          # double click, buy this unit
          $player.storefront.buy(info[:store_row])
        else
          # placed in some nonsense place, drop it back
          Mouse.drop(true)
        end
      end
    elsif Mouse.trigger?(1) && Mouse.grid != nil
      # right click
      if Mouse.holding?
        # drop whatever we're holding back where it came from
        Mouse.drop(true)
      else
        # update the static infobox
        ct = $infobox.cached_text
        if hex && hex.battler
          # equipped artifact hoverbox
          x, y = *Mouse.pos
          x_rcn = x - hex.pixel_x
          y_rcn = y - hex.pixel_y
          x_ind = x_rcn / 21
          if y_rcn.between?(27, 49) && hex.battler.artifacts.length > x_ind
            $infobox.update(hex.battler.artifacts[x_ind])
          else
            $infobox.update(hex.battler)
          end
        elsif syn_info
          # synergy tray hoverbox
          $infobox.update(syn_info)
        elsif a_sprite
          # artifact hoverbox
          $infobox.update(a_sprite.artifact)
        end
        if ct == $infobox.cached_text
          $infobox.update(nil)
          $infobox.cached_text = ""
        end
      end
    else
      # hover
      # update the hovering infobox
      if section == :infobox && $infobox.submenu
        $hoverbox.update($infobox.submenu.get_submenu)
        $hoverbox.z += 30
      elsif hex && hex.battler
        # equipped artifact hoverbox
        x, y = *Mouse.pos
        x_rcn = x - hex.pixel_x
        y_rcn = y - hex.pixel_y
        if y_rcn.between?(27, 49)
          x_ind = x_rcn / 21
          $hoverbox.update(hex.battler.artifacts[x_ind])
        end
      elsif syn_info
        # synergy tray hoverbox
        $hoverbox.update(syn_info)
      elsif a_sprite
        # artifact hoverbox
        $hoverbox.update(a_sprite.artifact)
      elsif store_info
        # store hoverboxes
        case store_info[:kind]
        when :unit
          # unit hoverbox
          $hoverbox.update(info[:unit_class])
        when :syn
          # synergy hoverbox
          $hoverbox.update(info[:handler], info[:unit_name])
        when :lock
          # lock hoverbox
          $hoverbox.update(:lock)
        when :streak
          # streak hoverbox
          $hoverbox.update(:streak)
        when :gold
          # income hoverbox
          $hoverbox.update(:gold)
        when :xp
          # xp hoverbox
          $hoverbox.update(:xp)
        when :refresh
          # refresh hoverbox
          $hoverbox.update(:refresh)
        end
      elsif aur
        $hoverbox.update(aur)
      else
        # not hovering over anything, clear the hoverbox
        $hoverbox.update(nil)
      end
    end
  end

  def mouse_script2
    case Mouse.section
    when :hexes
      # we're in the hexes
      # The hex we're over
      hex = $game_master.hex_from_mouse(*Mouse.pos)
      if !hex
        Mouse.hover(:hexes)
      elsif hex.battler
        Mouse.hover(hex.battler)
      else
        Mouse.hover(hex)
      end
      if (Mouse.trigger?(0) || Mouse.release?(0) > 12) && Mouse.grid != nil
        # Left Click
        # Try to pick up or place a battler
        
        # Check if we can edit this hex
        if hex && hex.start_player.id == 1 && hex.can_edit
          if Mouse.holding?.is_a?(Unit)
            # We're trying to place a Unit
            if hex.battler
              # there's something here, switch them
              Mouse.holding?.current_hex.battler = hex.battler
              hex.battler.update_hex(Mouse.holding?.current_hex, true)
            end
            # there's nothing here, place it
            hex.battler = Mouse.holding?
            Mouse.holding?.update_hex(hex, true)
            Mouse.drop
          elsif Mouse.holding?.is_a?(Sprite_Artifact)
            # equipping a unit
            if hex && hex.battler
              given = hex.battler.give_artifact(Mouse.holding?.artifact)
              Mouse.drop(!given)
            else
              Mouse.drop(true)
            end
          elsif Mouse.holding?.is_a?(Sprite)
            # We're moving from shop to the board
            # drop the clone sprite, try to buy if hex is empty
            prev_info = Mouse.holding?.holder
            prev_info[:sprite].opacity = 255
            Mouse.holding?.dispose
            Mouse.drop
            unless hex.battler
              $player.storefront.buy(prev_info[:store_row], hex)
            end
          elsif hex.battler
            # pick up a battler
            Mouse.hold(hex.battler)
            # leave @current_hex, we may need to put it back
            # may need to change this
            hex.battler = nil
          end
        elsif Mouse.holding?
          # we can't do stuff, drop the sprite back where it came from
          Mouse.drop(true)
        end
      elsif !Mouse.holding? && Mouse.trigger?(1) && Mouse.grid != nil
        # Right click, show infobox
        if hex && hex.battler
          $hoverbox.update(hex.battler)
        else
          $hoverbox.update(nil)
        end
      end
    when :store
      # we're in the store
      # selling a unit, we don't care where we are specifically
      if Mouse.holding?.is_a?(Unit) && (Mouse.trigger?(0) || Mouse.release?(0) > 12) && Mouse.grid != nil
        $player.storefront.sell(Mouse.holding?)
        Mouse.holding?.sprite.dispose
        Mouse.drop
        Mouse.hover(:store)
        return
      end
      info = nil
      info = $player.storefront.info_from_pos(*Mouse.pos) if $player && $player.storefront
      if !info
        # hovering over some empty section of the store
        Mouse.hover(:store)
      elsif info[:sprite]
        # hovering over a unit sprite
        Mouse.hover(info[:sprite])
      else
        # hovering over another shop section
        Mouse.hover(info[:kind])
      end

      if info == nil
        # in the blank bit of the store, clear the infobox
        $hoverbox.update(nil)
      else
        case info[:kind]
        when :unit
          # hovering over a unit
          # if we're left clicking, pick up a unit
          # if we're double left clicking, buy a unit
          # if we're right clicking, drop a unit or toggle the infobox
          # if we're not holding a unit, open the infobox
          # if we're not picking, dropping, buying, or opening, clear the infobox
          action = nil
          if (Mouse.trigger?(0) || Mouse.release?(0) > 12) && Mouse.grid != nil
            # left click
            if Mouse.holding?.is_a?(Sprite)
              # putting a shop item back, or double-click buy
              # fade back the shop sprite
              # dispose the sprite on the mouse
              # drop the sprite
              prev_info = Mouse.holding?.holder
              prev_info[:sprite].opacity = 255
              Mouse.holding?.dispose
              Mouse.drop
              # if this is the same unit, (ie double click), buy it
              if info[:store_row] == prev_info[:store_row]
                $player.storefront.buy(info[:store_row])
              end
            elsif !Mouse.holding?
              # picking up a shop item
              # fade out the shop sprite
              # create a copy hex sprite on the mouse
              # have the mouse hold the class
              info[:sprite].opacity = 100
              copy_spr = new_hex_sprite
              copy_spr.bitmap = info[:sprite].bitmap
              copy_spr.z = info[:sprite].z + 10
              copy_spr.holder = info
              copy_spr.on_mouse = true
              Mouse.hold(copy_spr)
            end
          else
            # hover
            $hoverbox.update(info[:unit_class])
          end
        when :syn
          # show the synergy infobox
          $hoverbox.update(info[:handler], info[:unit_name])
        when :lock
          # Change lock on left click
          $player.storefront.toggle_lock if Mouse.trigger?(0)
          # show the lock infobox
          $hoverbox.update(:lock)
        when :streak
          # show the streak infobox
          $hoverbox.update(:streak)
        when :gold
          # show the income infobox
          $hoverbox.update(:gold)
        when :xp
          # show the xp infobox
          $hoverbox.update(:xp)
          # buy xp on left click
          $player.storefront.buy_xp if Mouse.trigger?(0) && Mouse.grid != nil
        when :refresh
          # show the refresh infobox
          $hoverbox.update(:refresh)
          # buy reroll on left click
          $player.storefront.buy_reroll if Mouse.trigger?(0) && Mouse.grid != nil
        end
      end
    when :synergy
      # we're in the synergy tray
      syn = $game_master.players[0].syn_tray.syn_from_mouse(*Mouse.pos)
      if syn
        $hoverbox.update(syn)
        Mouse.hover(syn)
      else
        $hoverbox.update(nil)
        Mouse.hover(:synergy)
      end
    when :artifact
      info = $artifact_tray.info_from_pos(*Mouse.pos)
      a_sprite = (info.is_a?(Array) ? nil : info)
      # either position array or a sprite
      if a_sprite
        Mouse.hover(a_sprite)
      else
        Mouse.hover(:artifact)
      end
      if Mouse.grid != nil && (Mouse.trigger?(0) || Mouse.release?(0) > 12)
        # left click or drag and drop
        if Mouse.holding?.is_a?(Sprite_Artifact)
          # placing an artifact
          if a_sprite
            # on an artifact
            Mouse.hold($artifact_tray.swap(a_sprite, Mouse.holding?))
          else
            # on an empty place
            $artifact_tray.place(Mouse.holding?, *info)
            Mouse.drop
          end
        elsif Mouse.holding?
          # placing a random thing here that we need to put back
          Mouse.drop(true)
        elsif a_sprite
          # pick up the artifact
          Mouse.hold($artifact_tray.take(a_sprite))
        end
      else
        # hovering
        if a_sprite
          $hoverbox.update(a_sprite.artifact)
        else
          $hoverbox.update(nil)
        end
      end
    when :aura
    else
      $hoverbox.update(nil)
      Mouse.hover(nil)
    end
    # on right click while holding
    # drop whatever we're holding back where we got it
    if Mouse.holding? && Mouse.trigger?(1) && Mouse.grid != nil
      Mouse.drop(true)
    end
  end
end