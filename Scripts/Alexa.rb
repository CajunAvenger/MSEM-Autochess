class Alexa < Planeswalker
  def self.get_base_stats
    return {
      :name       => "Alexa",
      :cost       => 1,
      :synergy    => [:AKIEVA, :ARTIFICER],
      :range      => 4,
      :power      => [40, 60, 90],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 20,
      :ward       => 0,
      :life       => [500, 900, 1620],
      :ability_cost => 70,
      :starting_mana => 20.0,
      :mana_cooldown => 1.0,
      :pronoun    => "she/her"
    }
  end
  
#Alexa: akieva/artificer. good pickup early for snowballing with shop boost and items. support mage. 
#karma-alike sans carry potential. 
#Spell: Burgeoning Blooms. In a 3 hex burst, Alexa sprouts thorny vines and vibrant flowers, dealing MS-[210/280/350] 
#damage to enemies and shielding allies for MS-[210/280/350]

  def attack_sprite_file(attack_keys)
    return "Weapon/gthorn.png"
  end
  
  def self.ability_aim
    return [:aggro, 1]
  end
  
  def self.ability_area
    return [:burst, 1]
  end
end

module AbilityLibrary
  
  # Ability Script
  def ability_script_alexa(target_info, mana_cost=@ability_cost)
    if @empowered.include?(:LostInTheRoses) && @stacks[:alexa] != @owner.match.id
      # replace first spell cast with elemental
      @stacks[:alexa] = @owner.match.id
      tkn = Ardy_Elemental.new(@owner, @level)
      imps = [
        Impact.new(:MAX_LIFE, mana_amp),
        Impact.new(:POWER, mana_amp)
      ]
      Buff.new(self, tkn, imps)
      @owner.give_unit(tkn, self)
      return
    end
    abil_scale = [210, 210, 280, 350][@level] * mana_amp
    for hex in target_info[0] do
      if hex.controller == @owner
        r_rose = new_animation_sprite
        r_rose.bitmap = RPG::Cache.icon("Ability/rrose.png")
        r_rose.x = hex.pixel_x
        r_rose.y = hex.pixel_y
        r_rose.z = @sprite.z + 30
        r_rose.opacity = 0
        r_rose.add_fade_to(255, 0.3*fps)
        r_rose.add_damage(Damage_Ability.new(self, nil, abil_scale), "enemy")
        r_rose.add_wait(0.2*fps)
        r_rose.add_fade_to(0, 0.2*fps)
        r_rose.add_dispose
      else
        
        r_rose = new_animation_sprite
        r_rose.bitmap = RPG::Cache.icon("Ability/grose.png")
        r_rose.x = hex.pixel_x
        r_rose.y = hex.pixel_y
        r_rose.z = @sprite.z + 30
        r_rose.opacity = 0
        r_rose.add_fade_to(255, 0.3*fps)
        if hex.battler && hex.battler.owner == @owner
          friend = hex.battler
          shield = Proc.new do
            Buff.new(self, friend, Impact.new(:SHIELD, abil_scale), "Burgeoning Blooms")
          end
          r_rose.add_proc(shield)
        end
        r_rose.add_wait(0.2*fps)
        r_rose.add_fade_to(0, 0.2*fps)
        r_rose.add_dispose
      end
    end
  end
  
end

register_planeswalker(Alexa)