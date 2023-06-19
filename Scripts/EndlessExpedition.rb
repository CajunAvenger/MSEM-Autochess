class EndlessExpedition < Aura
  
  def self.get_base_stats
    return {
      :name => "Endless Expedition",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Scouts gain bonus",
      "mana amp and ward if you",
      "refreshed the shop at least",
      "twice since the last combat.",
      "Gain a Kati."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain a Kati
    give_unit(Kati)
    
    # Set up listener to apply to future Scouts
    scout = Proc.new do |listen, unit|
      next unless listen.host.refresh_counter >= 2
      for u in listen.host.deployed
        next unless u.synergies.include?(:SCOUT)
        imps = [
          Impact.new(:MANA_AMP, 30),
          Impact.new(:WARD, 10)
        ]
        Buff.new(self, u, imps)
      end
    end
    gen_subscription_to(@owner, :Deployed, scout)
  end

end

register_aura(EndlessExpedition)