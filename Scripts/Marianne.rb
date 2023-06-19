class Marianne < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Marianne",
      :cost       => 1,
      :synergy    => [:ROGUE, :GUNSLINGER],
      :range      => 4,
      :power      => [40, 60, 90],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 20,
      :ward       => 0,
      :life       => [500, 900, 1620],
      :ability_cost => 40.0,
      :starting_mana => 0.0,
      :mana_cooldown => 1.0,
      :slow_start => 0,
      :pronoun    => "she/her"
    }
  end

#Marianne: solid damage dealing early carry for gunslingers, good self buff to stack damage on esp with rogue
#Spell:Crossfire: Marianne twirls her guns, getting a MS-[20%/30%/40%] haste buff for her next 6 attacks.

  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/Marianne/bullet.png"
  end
  def six_sprite_file(attack_keys)
    return "Weapon/Marianne/six.png"
  end
  
end

module AbilityLibrary
  def ability_script_marianne(target_info, mana_cost=@ability_cost)
    boost = [0.2, 0.2, 0.3, 0.4][@level] * mana_amp
    imp = Impact.new(:HASTE_MULTI, boost)
    sbuff = Buff.new(self, self, imp, "Six Shooter")
    sbuff.counter = 6
    bullets = new_animation_sprite
    bullets.bitmap = RPG::Cache.icon("Ability/Gunslinger/bullets_6.png")
    bullets.add_stick_to(@sprite)
    bullets.z = @sprite.z + 30
    @sprite.subsprites.push(bullets)
    fire = Proc.new do |listen, attack_keys|
      sbuff.counter -= 1
      if sbuff.counter == 0
        sbuff.clear_buff()
        bullets.dispose
        listen.fragile = true
      else
        bullets.bitmap = RPG::Cache.icon("Ability/Gunslinger/bullets_"+sbuff.counter.to_s+".png")
      end
    end
    gen_subscription_to(self, :Attacking, fire)
  end
end

register_planeswalker(Marianne)