class Omegalomania < Aura
  
  def self.get_base_stats
    return {
      :name => "Omegalomania",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "When one of your Akieva",
      "planeswalkers kills an enemy,",
      "that unit briefly fights",
      "under your control.",
      "Gain a Volta."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def extra_init
    # Gain a Volta
    give_unit(Volta)
    
    deathstroke = Proc.new do |listen, killer, dead, hex, *args|
      next unless killer.synergies.include?(:AKIEVA)
      holdp = dead.owner
      dead.dead = false
      dead.current_damage = 0
      dead.owner = listen.subscriber.owner
      hex.set_battler(dead)
      listen.subscriber.owner.deployed.push(dead)
      sc = dead.sprite.add_schedule
      dead.sprite.pop(:opacity, sc-1, true)
      dead.sprite.add_fade_to(255, 0.1*dead.fps, sc-1)
      dead.sprite.vis(true)
      dead.update_life
      dead.emit(:Revived, self)
      rem = (@owner.match.max_combat_frames - @owner.match.combat_frames - 1).cap(2*$frames_per_second)
      give_back = Proc.new do |frames|
        @owner.sacrifice(dead)
        dead.owner = holdp
      end
      $timer.add_framer(rem, give_back)
    end
    gen_subscription_to(@owner, :Killed, deathstroke)
    
  end

end

register_aura(Omegalomania)