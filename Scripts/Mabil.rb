class Mabil < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Mabil",
      :display    => "Mabil Fardancer",
      :cost       => 3,
      :synergy    => [:CONVERGENT, :BARD],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:ally, 1]
  end
  
  def self.ability_area
    return [:cone, 2]
  end
  
end

module AbilityLibrary
  def ability_script_mabil(target_info, mana_cost=@ability_cost)

    spr = new_animation_sprite
    spr.bitmap = RPG::Cache.icon("Ability/Bard/glyre.png")
    spr.x = @sprite.x - 10
    spr.y = @sprite.y
    spr.z = @sprite.z + 20
    spr.add_translate(20, 0, 0.2*fps)
    spr.add_translate(-10, 0, 0.1*fps)
    spr.add_wait(0.4*fps)
    spr.add_dispose
    tags = []
    for h in target_info[0]
      next if h == @current_hex
      next unless h.controller == @owner
      gnote = new_animation_sprite
      gnote.x = @sprite.x-32
      gnote.y = @sprite.y
      gnote.z = @sprite.z + 25
      gnote.bitmap = RPG::Cache.icon("Ability/Bard/gnote.png")
      gnote.visible = false
      gnote.add_wait(0.15*fps-1)
      gnote.switch_visible
      
      unote = new_animation_sprite
      unote.x = @sprite.x+32
      unote.y = @sprite.y
      unote.z = @sprite.z + 25
      unote.bitmap = RPG::Cache.icon("Ability/Bard/unote.png")
      unote.visible = false
      unote.add_wait(0.3*fps-1)
      unote.switch_visible
      gnote.add_slide_to(h.battler.sprite, 0.2*fps, -32)
      unote.add_slide_to(h.battler.sprite, 0.2*fps, 32)
      gnote.add_orbit(h.battler.sprite, 32, 48, 3.6*fps, 3/2*Math::PI)
      unote.add_orbit(h.battler.sprite, 32, 48, 3.6*fps, 1/2*Math::PI)
      gnote.add_dispose()
      unote.add_dispose()
      efs = []
      tags.push(h.battler)
      haste = mana_amp-0.8
      efs = Impact.new(:HASTE_MULTI, haste)
      Buff_Timed.new(self, h.battler, efs, 4, "Mabil's Song")
    end
    himpact = Heal.new(100*mana_amp)
    heal = Proc.new do |frames|
      for t in tags
        next if t.dead
        t.apply_heal(himpact)
      end
    end
    $timer.add_framer(0.3*fps, heal)
  end
end

register_planeswalker(Mabil)