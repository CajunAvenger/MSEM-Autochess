class Kati < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Kati",
      :display    => "Kati Evalin",
      :cost       => 2,
      :synergy    => [:ARCANUM, :AKIEVA, :SCOUT],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => 100,
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/gsword.png"
  end
  
end

module AbilityLibrary
  def ability_script_kati(target_info, mana_cost=@ability_cost)
    pow = 30 * mana_amp
    for targetHex in target_info[0]
      next unless targetHex.controller == @owner
      efs = Impact.new(:POWER, pow)
      mbuff = Buff.new(self, targetHex.battler, efs)
      efs = Impact.new(:POWER_MULTI, 0.3)
      pbuff = Buff_Timed.new(self, targetHex.battler, efs, 3)
      spr = new_animation_sprite()
      spr.bitmap = RPG::Cache.icon("Ability/Hexes/green.png")
      spr.z = targetHex.battler.sprite.z + 20
      spr.opacity = 0
      spr.add_stick_to(targetHex.battler.sprite)
      spr.add_fade_to(128, 0.5*fps, 1)
      spr.add_wait(2*fps, 1)
      spr.add_fade_to(0, 0.5*fps, 1)
      spr.add_dispose(1)
    end
  end
end

register_planeswalker(Kati)