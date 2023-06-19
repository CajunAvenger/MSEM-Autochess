class Lucien < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Lucien",
      :cost       => 2,
      :synergy    => [:THESPIAN, :WARRIOR],
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
    return "Weapon/rsword.png"
  end
  
end

module AbilityLibrary
  def ability_script_lucien(target_info, mana_cost=@ability_cost)
    unless @stacks[:lucien]
      # create the base buff if we don't have one yet
      @stacks[:lucien] = [Impact.new(:HASTE, 0), nil]
      Buff_Eternal.new(self, self, @lucien_impact, "Lucien's Hunger")
    end
    
    # proc that stacks our haste
    haste_stack = Proc.new do |target, amount|
      @stacks[:lucien][0].amount += 0.2 if target.dead
    end
    
    # proc that boosts damage and executes
    execution = Proc.new do |listen, attack_keys|
      attack_keys[:extra_p] += 40
      attack_keys[:salva] = true
      if !attack_keys[:execute] || attack_keys[:execute] > 0.2
        attack_keys[:execute] = 0.2
      end
      if @stacks[:lucien][1] != @owner.match.id
        @stacks[:lucien][1] = @owner.match.id
        attack_keys[:procs].push(haste_stack)
      end
    end
    l = gen_subscription_to(self, :Attacking, execution)
    l.fragile = true
  end
end

register_planeswalker(Lucien)
