class Dragongate < Aura
  
  def self.get_base_stats
    return {
      :name => "Dragongate",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "When you combined items",
      "on a Draconic planeswalker,",
      "gain a 1-star copy of it.",
      "Gain a Flynn."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain an Flynn
    give_unit(Flynn)
    
    upgrade = Proc.new do |listen, holder, *args|
      next unless holder.synergies.include?(:DRACONIC)
      listen.host.give_unit(holder.class.new)
    end
    gen_subscription_to(@owner, :Upgraded, upgrade)
  end

end

register_aura(Dragongate)