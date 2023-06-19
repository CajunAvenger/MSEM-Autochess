class Belligerence < Aura
  
  def self.get_base_stats
    return {
      :name => "Belligerence",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your living Warrior with",
      "the greatest toughness gains",
      "large amounts of bonus power.",
      "Gain a Helene."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain a Helene
    give_unit(Helene)
        
    match_setter = Proc.new do |listen|
      listen.subscriber.find_high
    end
    gen_subscription_to(@owner, :Deployed, match_setter)
  end
  
  def find_high
    hold = [0, nil]
    for u in @owner.deployed
      next unless u.synergies.include?(:WARRIOR)
      t = u.get_value(:TOUGHNESS)
      if t > hold[0]
        hold = [t, u]
      end
    end
    return unless hold[1]
    Buff.new(self, hold[1], Impact.new(:POWER, 60))
    mid = @owner.match.id
    resetter = Proc.new do |listen, *args|
      next if listen.host.owner.match.id != mid
      listen.subscriber.find_high
    end
    l = gen_subscription_to(hold[1], :Died, resetter)
    l.fragile = true
  end

end

register_aura(Belligerence)