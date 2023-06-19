class Ajani < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Ajani",
      :cost       => 4,
      :synergy    => [:ALARA, :CAT, :WARRIOR],
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
  
end

module AbilityLibrary
  def ability_script_ajani(target_info, mana_cost=@ability_cost)
    # Gain a mana-scaling damage shield,
    # and bonus power scaling with the amount of remaining shield.
    sh = 400 * mana_amp
    shield = Shield.new(sh)
    power = Impact_Linked.new(:POWER, 0.1, shield)
    imps = [shield, power]
    Buff.new(self, self, imps)
  end
end

register_planeswalker(Ajani)
