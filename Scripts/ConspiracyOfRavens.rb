class ConspiracyOfRavens < Aura
  
  def self.get_base_stats
    return {
      :name => "Conspiracy of Ravens",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Know which enemy you'll",
      "fight next each round.",
      "They know they'll fight you,",
      "and their shop costs are increased."
    ]
  end
  
  def self.sprite
    return "Spend"
  end

  def extra_init
    
    @owner.empowered.push(:foresight)
    @owner.empowered.push(:announcing)

    tax = Proc.new do |listen|
      opp = listen.host.match.other_player(listen.host)
      console.log(opp.name)
      opp.storefront.round_tax += 3 if opp.storefront
      console.log(opp.storefront.round_tax)
    end
    gen_subscription_to(@owner, :MatchBuilt, tax)
  end

end

register_aura(ConspiracyOfRavens)