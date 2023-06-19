class Infobox < Sprite_Chess
  attr_accessor :cached_text
  attr_accessor :submenu
  def initialize(vp)
    super
    self.visible = false
    self.bitmap = Bitmap.new("Graphics/Icons/Infobox.png")
    self.bitmap.font.size = 17
    self.bitmap.font.color.set(255,255,255)
    @cached_text = ""
    @subsprites = []
  end
  
  def update(obj, extra=nil)
    unless obj
      self.visible = false
      for s in @subsprites
        s.dispose
      end
      @subsprites = []
      @submenu = nil
      return
    end

    if obj.has_infobox?
      obj.write_to_infobox(self, extra)
    else
      case obj
      when :lock
        text = ($player.storefront.locked ? "Locked" : "Unlocked")
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(10, 6, 128, 24, text)
          if $player.storefront.locked
            self.bitmap.draw_text(10, 30, 170, 24, "Shop won't refresh")
          else
            self.bitmap.draw_text(10, 30, 170, 24, "Shop will refresh")
          end
          self.bitmap.draw_text(10, 50, 170, 24, "at end of rounds.")
        end
      when :streak
        text = ""
        if $player.streak < 0
          text = "Loss"
        else
          text = "Win"
        end
        text += " Streak: " + $player.streak.abs().to_s
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(10, 6, 128, 24, text)
          gold_string = ""
          for i in 1..$Streak_Base.length-1
            gold_string += $Streak_Base[i].to_s
            gold_string += "/" unless i == $Streak_Base.length-1
          end
          self.bitmap.draw_text(10, 30, 170, 24, "Streaks earn " + gold_string)
          self.bitmap.draw_text(10, 50, 170, 24, "gold per round")
        end
      when :gold
        vals = $player.calc_income
        tot = vals[0] + vals[1] + vals[2] + vals[3]
        # [streak_gold, interest, passive, win]
        l1 = "Streak gold: +" + vals[0].to_s
        l2 = "Round interest: +" + vals[1].to_s
        l3 = "Passive gold: +" + vals[2].to_s
        l4 = "Win gold: +" + vals[3].to_s
        text = l1+l2+l3+l4
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_mini.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(10, 6, 128, 24, "Income: +" + tot.to_s)
          self.bitmap.draw_text(10, 30, 170, 24, l1)
          self.bitmap.draw_text(10, 50, 170, 24, l2)
          self.bitmap.draw_text(10, 70, 170, 24, l3)
          self.bitmap.draw_text(10, 90, 170, 24, l4)
        end
      when :xp
        text = "xp"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(10, 6, 170, 24, "Buy Experience - 4 Gold")
          self.bitmap.draw_text(10, 30, 170, 24, "Buy 4 xp towards")
          self.bitmap.draw_text(10, 50, 170, 24, "next level.")
        end
      when :refresh
        text = "refresh"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(10, 6, 170, 24, "Refresh - 2 Gold")
          self.bitmap.draw_text(10, 30, 170, 24, "Get new store options.")
        end
      when :power
        text = "power"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Power")
          self.bitmap.draw_text(7, 30, 170, 24, "Basic attack damage.")
        end
      when :multi
        text = "multi"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Multistrike")
          self.bitmap.draw_text(7, 30, 170, 24, "Chance to attack")
          self.bitmap.draw_text(7, 50, 170, 24, "a second time.")
        end
      when :haste
        text = "haste"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Haste")
          self.bitmap.draw_text(7, 30, 170, 24, "Attacks per second")
          self.bitmap.draw_text(7, 50, 170, 24, "and action speed.")
        end
      when :mana_amp
        text = "mana amp"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Mana amp")
          self.bitmap.draw_text(7, 30, 170, 24, "Spell effect multiplier.")
        end
      when :archive
        text = "archive"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Archive")
          self.bitmap.draw_text(7, 30, 170, 24, "Mana gained multiplier.")
        end
      when :range
        text = "range"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Range")
          self.bitmap.draw_text(7, 30, 170, 24, "Basic attack range.")
        end
      when :toughness
        text = "toughness"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Toughness")
          self.bitmap.draw_text(7, 30, 170, 24, "Reduces attack damage.")
        end
      when :ward
        text = "ward"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Ward")
          self.bitmap.draw_text(7, 30, 170, 24, "Increase cost of enemy")
          self.bitmap.draw_text(7, 50, 170, 24, "spells targeting this.")
        end
      when :mana
        text = "mana"
        if text != @cached_text
          @cached_text = text
          self.bitmap = Bitmap.new("Graphics/Icons/Infobox_micro.png")
          self.bitmap.font.name = "Fontin"
          self.bitmap.font.size = 17
          self.bitmap.font.color.set(255,255,255)
          self.bitmap.draw_text(7, 6, 170, 24, "Mana")
          self.bitmap.draw_text(7, 30, 170, 24, "Spell will try to")
          self.bitmap.draw_text(7, 50, 170, 24, "cast at max mana.")
        end
      end
    end
    x, y = Mouse.pos
    self.x = x + 20
    self.z = 9999
    self.visible = true
    self.y = y + 20
    # make sure we don't spill over the left edge
    self.x = 0 if self.x < 0
    # make sure we don't spill over the right edge
    spill_x = self.x + self.bitmap.width - $Screen_W
    self.x -= spill_x if spill_x > 0
    # make sure we don't spill over the top
    self.y = 0 if self.y < 0
    # make sure we don't spill over the bottom
    spill_y = self.y + self.bitmap.height - $Screen_H
    self.y -= spill_y if spill_y > 0
  end
end

$hoverbox = nil