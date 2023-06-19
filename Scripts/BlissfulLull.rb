class BlissfulLull < Aura
  
  def self.get_base_stats
    return {
      :name => "Blissful Lull",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Until you buy a planeswalker,",
      "gain a Mageweave Cloak at",
      "the start of each combat."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    collect = Proc.new do |listen, unit|
      listen.host.give_artifact(Artifact_MageweaveCloak.new)
    end
    @match_listener = gen_subscription_to(@owner, :Deployed, collect)
    
    check_out = Proc.new do |listen, *args|
      listen.subscriber.deactivate
    end
    gen_subscription_to(@owner, :UnitBought, check_out)
  end
  
  def deactivate
    @match_listener.clear_listener
    @active = false
  end

end

register_aura(BlissfulLull)