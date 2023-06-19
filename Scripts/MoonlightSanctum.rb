class MoonlightSanctum < Aura
  attr_accessor :combat_cache
  
  def self.get_base_stats
    return {
      :name => "Moonlight Sanctum",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Felices start each",
      "combat with a shield that",
      "blocks damage scaling",
      "with her mana amp.",
      "Gain two Felice."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init
    
    give_unit(Felice)
    give_unit(Felice)
    
    # shield Felice at start of combat
    cache = Proc.new do |listen|
      console.log(listen.host.deployed.length)
      listen.subscriber.combat_cache = []
      for u in listen.host.deployed
        next unless u.name == "Felice"
        Buff.new(self, u, Shield.new(200*u.mana_amp))
      end
    end
    gen_subscription_to(@owner, :Deployed, cache)

  end

end

register_aura(MoonlightSanctum)