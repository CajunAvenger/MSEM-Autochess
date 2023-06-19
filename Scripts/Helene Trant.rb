class Helene < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Helene",
      :display    => "Helene Trant",
      :cost       => 2,
      :synergy    => [:ALARA, :WARRIOR],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [750, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:area, 1]
  end
  
end

module AbilityLibrary
  def ability_script_helene(target_info, mana_cost=@ability_cost)
    # Gain a shield that outright negates the next enemy spell.
    # Gain a mana-scaling amount of bonus power while the shield is active.
    shield = Shield_Stocked.new(1, [Damage_Ability])
    pow = Impact.new(:POWER, 100*mana_amp)
    hbuff = Buff.new(self, self, [shield, pow])
    juke = Proc.new do |listen, targeter, target_info|
      target_info[0].delete(listen.host.current_hex)
      for d in target_info[1]
        d[:hexes].delete(listen.host.current_hex)
        d[:targets].delete(listen.host.current_hex) if d[:targets]
      end
      listen.subscriber.clear_buff
    end
    hbuff.gen_subscription_to(self, :BeingTargetedEnemy, juke)
    ssprite = new_animation_sprite
    ssprite.bitmap = RPG::Cache.icon("Ability/Helene_shield.png")
    ssprite.z = @sprite.z+1
    ssprite.x = @sprite.x
    ssprite.y = @sprite.y
    ssprite.add_stick_to(@sprite)
    hbuff.board_sprite = ssprite
  end
end

register_planeswalker(Helene)
