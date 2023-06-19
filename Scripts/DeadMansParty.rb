class DeadMansParty < Aura
  
  def self.get_base_stats
    return {
      :name => "Dead Man's Party",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Assassins jump to another",
      "target and remove 50% of their",
      "spell'scharge when they get one",
      "or more kills.",
      "Gain an Eli."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain an Eli
    give_unit(Eli)
    
    # Apply to existing Assassins
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Assassins
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:ASSASSIN)
    @frames[unit.id] = [-1, -1]
    jump = Proc.new do |listen, *args|
      mid = listen.host.owner.match.id
      mfr = listen.host.owner.match.combat_frames
      ch = listen.subscriber.frames[listen.host.id]
      next if ch[0] == mfr && ch[1] == mid
      ag = listen.host.get_dash_target(4)
      targ = ag[0]
      landing = ag[1]
      next unless targ && landing
      next unless landing.set_battler(listen.host)
      targ.battler.mana = targ.battler.mana/2
      targ.battler.update_mana
      listen.subscriber.frames[listen.host.id] = [mfr, mid]
    end
    
    gen_subscription_to(unit, :Killed, jump)
    @enchanting.push(unit)
  end

end

register_aura(InsurgentBallads)