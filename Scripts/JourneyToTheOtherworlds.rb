class JourneyToTheOtherworlds < Aura
  
  def self.get_base_stats
    return {
      :name => "Journey to the Otherworlds",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "If you have multiple copies",
      "of a planeswalker in play,",
      "they each charge their spell",
      "when the other casts."
    ]
  end
  
  def self.sprite
    return "Collect"
  end

  def extra_init
    
    collect = Proc.new do |listen, unit, *args|
      for u in listen.host.deployed
        next if u == unit
        next unless u.name == unit.name
        u.apply_mana_heal(ManaHeal.new(10))
      end
    end
    gen_subscription_to(@owner, :UsedAbility, collect)
  end

end

register_aura(JourneyToTheOtherworlds)