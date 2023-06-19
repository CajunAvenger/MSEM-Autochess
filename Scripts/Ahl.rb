class Ahl < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Ahl",
      :display    => "Ahl Strixian",
      :cost       => 2,
      :synergy    => [:MIRRORWALKER, :AERIAL],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/uray.png"
  end
  
end

module AbilityLibrary
  def ability_script_ahl(target_info, mana_cost=@ability_cost)
    sbuff = Buff.new(self, self, Shield.new(100*mana_amp), "Mirror Ward")
    aoe_hash = {
      :epicenter => self,
      :range => 2,
      :follow => true,
      :source => self
    }
    aoe_hash[:impacter] = Proc.new do |aoe, unit|
      ef1 = Impact.new(:TOUGHNESS, 50)
      ef2 = Impact.new(:WARD, 50)
      [ef1, ef2]
    end
    pairs = [
      [0, 0],
      [-$hex_width, 0],
      [$hex_width, 0],
      [-$hex_width/2, -$hex_drop],
      [$hex_width/2, -$hex_drop],
      [-$hex_width/2, $hex_drop],
      [$hex_width/2, $hex_drop],
      [-2*$hex_width, 0],
      [2*$hex_width, 0],
      [0, -2*$hex_drop],
      [0, 2*$hex_drop],
      [-$hex_width, -2*$hex_drop],
      [-$hex_width, 2*$hex_drop],
      [$hex_width, -2*$hex_drop],
      [$hex_width, 2*$hex_drop],
      [-3*$hex_width/2, -$hex_drop],
      [3*$hex_width/2, -$hex_drop],
      [-3*$hex_width/2, $hex_drop],
      [3*$hex_width/2, $hex_drop]
    ]
    hexes = []
    for p in pairs
      hex = new_animation_sprite
      hex.bitmap = RPG::Cache.icon("Ability/Hexes/blue.png")
      hex.opacity = 60
      hex.z = @sprite.z - 22
      hex.add_stick_to(@sprite, 0, p[0], p[1])
      hexes.push(hex)
    end

    aoe = AoE_Boon.new(aoe_hash)
    fizzle = Proc.new do |listen|
      a = aoe
      a.clear_aoe
      for s in hexes
        s.dispose
      end
    end
    gen_subscription_to(sbuff, :Expired, fizzle)

  end
end

register_planeswalker(Ahl)