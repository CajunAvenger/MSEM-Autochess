class EndlessRepentance < Aura
  
  def self.get_base_stats
    return {
      :name => "Endless Repentance",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "The first time each combat",
      "one of your Clerics would die,",
      "fully heal it instead.",
      "Gain a Bahum."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain an Bahum
    give_unit(Bahum)
    
    @stacks = [-1]
    
    revive = Proc.new do |listen, dead, *args|
      next unless dead.synergies.include?(:CLERIC)
      next if listen.subscriber.stacks[0] == listen.host.match.id
      listen.subscriber.stacks[0] = listen.host.match.id
      dead.current_damage = 0
    end
    gen_subscription_to(@owner, :Dying, revive)
  end

end

register_aura(EndlessRepentance)