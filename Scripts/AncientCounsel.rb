class AncientCounsel < Aura
  attr_accessor :gain_listen
  def self.get_base_stats
    return {
      :name => "Ancient Counsel",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Lose less health for",
      "losing rounds. When you",
      "reach max team size,",
      "lose this aura and",
      "gain a two-star Azamir."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init

    gainer = Proc.new do |listen, amount|
      up = 13
      listen.host.life += up.cap(amount)
    end
    @gain_listen = gen_subscription_to(@owner, :LostLife, gainer)

    leveler = Proc.new do |listen|
      next unless listen.host.level == 9
      listen.subscriber.gain_listen.clear_listener
      listen.subscriber.give_unit(Azamir, 2)
    end
    gen_subscription_to(@owner, :LevelUp, leveler)
  end

end

register_aura(AncientCounsel)