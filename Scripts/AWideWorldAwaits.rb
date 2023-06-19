class AWideWorldAwaits < Aura
  
  def self.get_base_stats
    return {
      :name => "A Wide World Awaits",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "At the start of each combat,",
      "gain XP for each Convergent",
      "planeswalker you have.",
      "Gain a Mabil."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    
    # Gain an Mabil
    give_unit(Mabil)
    
    # Set up listener to count starred up Necromancers
    cacher = Proc.new do |listen, unit|
      counter = 0
      for u in listen.host.deployed
        counter += 1 if u.synergies.include?(:CONVERGENT)
      end
      listen.host.gain_xp(counter)
    end
    gen_subscription_to(@owner, :Deployed, cacher)
    
  end

end

register_aura(AWideWorldAwaits)