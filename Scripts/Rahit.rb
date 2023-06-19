class Rahit < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Rahit",
      :cost       => 1,
      :synergy    => [:ARCANUM, :ARTIFICER],
      :range      => 2,
      :power      => [40, 60, 90],
      :multi      => 10,
      :haste      => 0.6,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 40,
      :ward       => 10,
      :life       => [700, 1260, 2270],
      :ability_cost => 70,
      :starting_mana => 20.0,
      :mana_cooldown => 1.0,
      :slow_start => 0,
      :pronoun    => "he/him"
    }
  end

#Rahit: offtank mage, vlad-alike that sits behind tanks and helps them live and cast more. charges arcanum spells
#Spell:Recalculation: Rahit organizes the flows of magic around adjacent allies, shielding them from MS-[200/300/400] 
#damage from spells and granting them F-[10/15/20] charge.

  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/usword.png"
  end
  
end

module AbilityLibrary
  def ability_script_rahit(target_info, mana_cost=@ability_cost)
    mheal = [10, 10, 15, 20][@level] * mana_amp
      sh = [200, 200, 300, 400][@level] * mana_amp
    for h in target_info[0]
      next if h == @current_hex
      next unless h.controller == @owner
      efs = Shield.new(sh, [Damage_Ability])
      h.battler.apply_mana_heal(ManaHeal.new(mheal))
      rbuff = Buff.new(self, h.battler, efs, "Reconsider")
      spr = new_animation_sprite
      spr.bitmap = RPG::Cache.icon("Ability/Hexes/blue.png")
      spr.x = h.battler.sprite.x
      spr.y = h.battler.sprite.y
      spr.z = h.battler.sprite.z + 20
      spr.opacity = 0
      spr.add_stick_to(h.battler.sprite)
      spr.add_fade_to(128, 0.5*fps, 1)
      rbuff.board_sprite = spr
    end
  end
end

register_planeswalker(Rahit)