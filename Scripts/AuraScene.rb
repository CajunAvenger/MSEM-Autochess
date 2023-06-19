class AuraScene < Sprite
  Xs = [104, 413, 722]
  Ys = [186, 186, 186]
  
  def initialize(tier=1)
    super($scene.spriteset.viewport3)
    r1 = rand($auras.length)
    r2 = rand($auras.length)
    r3 = rand($auras.length)
    while r2 == r1
      r2 = rand($auras.length)
    end
    while r3 == r2 || r3 == r1
      r3 = rand($auras.length)
    end
    
    @rolls = [$auras[r1], $auras[r2], $auras[r3]]
    
    self.bitmap = Bitmap.new("Graphics/Icons/aura_scene.png")
    self.x = 0
    self.y = 0
    self.z = 9500
    self.bitmap.font.name = "Fontin"
    self.bitmap.font.size = 20
    self.bitmap.font.color.set(255,255,255)
    self.bitmap.draw_text(Xs[0], Ys[0], 236, 19, @rolls[0].get_base_stats[:name], 1)
    self.bitmap.draw_text(Xs[1], Ys[1], 236, 19, @rolls[1].get_base_stats[:name], 1)
    self.bitmap.draw_text(Xs[2], Ys[2], 236, 19, @rolls[2].get_base_stats[:name], 1)
    
    r = Rect.new(0, 0, 128, 128)
    bm1 = Bitmap.new("Graphics/Icons/AuraBig/"+@rolls[0].sprite+".png")
    bm2 = Bitmap.new("Graphics/Icons/AuraBig/"+@rolls[1].sprite+".png")
    bm3 = Bitmap.new("Graphics/Icons/AuraBig/"+@rolls[2].sprite+".png")
    self.bitmap.blt(Xs[0]+54, Ys[0]+26, bm1, r)
    self.bitmap.blt(Xs[1]+54, Ys[1]+26, bm2, r)
    self.bitmap.blt(Xs[2]+54, Ys[2]+26, bm3, r)
    
    for a in 0..@rolls.length-1
      aura = @rolls[a]
      desc = aura.get_description
      ht = 20*desc.length
      off = (120 - ht)/2
      y_start = Ys[a] + 167 + off
      for d in desc
        self.bitmap.draw_text(Xs[a], y_start, 236, 24, d, 1)
        y_start += 20
      end
    end
  end
  
  def choose(x, y)
    return nil unless y.between?(Ys[0], Ys[0]+300)
    return nil if x < Xs[0] || x > Xs[2] + 256
    ind = nil
    if x.between?(Xs[0], Xs[0]+256)
      ind = 0
    elsif x.between?(Xs[1], Xs[1]+256)
      ind = 1
    elsif x.between?(Xs[2], Xs[2]+256)
      ind = 2
    end
    return nil unless ind
    $player.give_aura(@rolls[ind].new($player))
    self.dispose
    $aura_scene = nil
  end
end
$aura_scene = nil

def start_aura_scene(tier=1)
  $aura_scene = AuraScene.new(tier)
end