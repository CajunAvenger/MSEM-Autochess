class Ardy < Planeswalker
  attr_reader :elemental        # keep track of our elemental token
  
  def self.get_base_stats
    return {
      :name       => "Ardy",
      :cost       => 1,
      :synergy    => [:ARCANUM, :WIZARD],
      :range      => 3,
      :power      => [40, 60, 90],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 20,
      :ward       => 0,
      :life       => [500, 900, 1620],
      :ability_cost => 150,
      :starting_mana => 100.0,
      :mana_cooldown => 1.0,
      :slow_start => 0,
      :pronoun    => "he/him"
    }
  end
  
#Ardy: arcanum/wizard. early power by adding more units to the board, maybe scales poorly? 
#Spell: Ardy's Invocation. Ardy summons an elemental token of roiling earth with MS-[300/400/500] health, MS-[40/50/60]
#power, F-10 multistrike, F-0.7 haste, F-100 mana-amp, F-100 archive, F-40 toughness, F-10 ward. If it's already alive, 
#instead heal it MS-200 and give it 20% haste for 5 seconds.
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/brrock.png"
  end
  
end

module AbilityLibrary
  
  def ability_script_ardy(target_info, mana_cost=@ability_cost)
    if !@stacks[:ardy] || @stacks[:ardy].dead
      # if we don't have the elemental, spawn it
      @stacks[:ardy] = Ardy_Elemental.new(@owner, @level)
      imps = [
        Impact.new(:MAX_LIFE, mana_amp),
        Impact.new(:POWER, mana_amp)
      ]
      Buff.new(self, @stacks[:ardy], imps)
      @owner.give_unit(@stacks[:ardy], self)
    else
      # if we do, heal it
      @stacks[:ardy].apply_heal(Impact.new(:HEALING, 200 * mana_amp))
      # then give 20% for 5s
      ef = Impact.new(:HASTE_MULTI, 0.2)
      haste = Buff_Timed.new(self, @stacks[:ardy], [ef], 5, "Cram Session")
    end
  end

end

class Ardy_Elemental < Token
  
  def self.get_base_stats
    return {
      :name       => "Ardy Elemental",
      :cost       => 1,
      :synergy    => [],
      :range      => 1,
      :power      => [40, 50, 60],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 40,
      :ward       => 10,
      :life       => [300, 400, 500]
    }
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/grock.png"
  end

end

register_planeswalker(Ardy)