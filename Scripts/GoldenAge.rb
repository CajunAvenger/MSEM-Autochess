class GoldenAge < Aura
  
  def self.get_base_stats
    return {
      :name => "Golden Age",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain bonus gold whenever",
      "you combine artifacts."
    ]
  end
  
  def self.sprite
    return "Recieve"
  end
  
  def self.can_be_given_to?(player)
    return 0 if player.auras.any?(self)
    return 0 if player.auras.any?(Disassociate)
    return 1
  end


  def extra_init
    
    kaching = Proc.new do |listen, *args|
      listen.host.give_gold(10, self)
    end
    gen_subscription_to(@owner, :Upgraded, kaching)

  end

end

register_aura(GoldenAge)