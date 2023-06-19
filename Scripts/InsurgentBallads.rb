class InsurgentBallads < Aura
  
  def self.get_base_stats
    return {
      :name => "Insurgent Ballads",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Bards gain bonus power",
      "and mana amp when attacking",
      "enemies with unusually",
      "high max life.",
      "Gain a Mabil."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    
    # Gain an Mabil
    give_unit(Mabil)
    
    # Apply to existing Bards
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Bards
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:BARD)
    high_life = 1000
    bonus_power = Proc.new do |listen, attack_keys|
      if attack_keys[:aggro].get_value(:MAX_LIFE) >= high_life
        attack_keys[:extra_p] += 40
      end
    end
    bonus_amp = Proc.new do |listen, target_info, cost, key|
      pump = false
      for h in target_info[0]
        next unless h.battler
        next if h.battler.owner == @owner
        pump = true if h.battler.get_value(:MAX_LIFE) >= high_life
      end
      listen.host.temp_amp += 40 if pump
    end
    
    gen_subscription_to(unit, :Attacking, bonus_power)
    gen_subscription_to(unit, :Casting, bonus_amp)
    @enchanting.push(unit)
  end

end

register_aura(InsurgentBallads)