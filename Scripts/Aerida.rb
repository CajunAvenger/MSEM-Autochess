class Aerida < Planeswalker
#Gain stacking mana-scaling haste and archive. At max stacks, stun all enemies.
  def self.get_base_stats
    return {
      :name       => "Aerida",
      :cost       => 2,
      :synergy    => [:ARCANUM, :ELDER, :CHRONOMANCER],
      :range      => [2, 2, 2],
      :power      => [20, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [2450, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/usword.png"
  end
  
end

module AbilityLibrary
  def ability_script_aerida(target_info, mana_cost=@ability_cost)
    max = 5
    stun = false
    stun_dura = 2
    arch_stack = 20
    haste_stack = 0.2
    @stacks[:aerida] = [nil, nil] unless @stacks[:aerida]
    if @stacks[:aerida][1] == @owner.match.id
      # increase stacks
      @stacks[:aerida][0].amount += 1 unless @stacks[:aerida][0].amount >= max
      stun = true if @stacks[:aerida][0].amount >= max
    else
      # restart stacks
      @stacks[:aerida] = [Impact.new(:AeridaStacks, 1), @owner.match.id]
      efs = [
        Impact_Linked.new(:HASTE_MULTI, haste_stack, @stacks[:aerida][0]),
        Impact_Linked.new(:ARCHIVE, arch_stack, @stacks[:aerida][0])
      ]
      Buff.new(self, self, efs, "Aerida Stack")
    end

    if stun
      for u in @owner.opponent.deployed
        Debuff_Timed.new(self, u, Impact.new(:STUN, 1), stun_dura)
      end
    end
    
  end
end

register_planeswalker(Aerida)