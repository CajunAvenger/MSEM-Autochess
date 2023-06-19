class DestabilizingTheRifts < Aura

  def self.get_base_stats
    return {
      :name => "Destabilizing the Rifts",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "When an enemy unit kills",
      "one of your units, teleport",
      "it to a random location.",
      "Gain an Aerida."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init
    
    give_unit(Aerida)
    
    # cache units around a Helena at start of combat
    boink = Proc.new do |listen, dead, dead2, hex, damage_event|
      next unless damage_event
      next unless damage_event.source.is_a?(Unit)
      frees = []
      for id, h in listen.host.match.board.board_map
        console.log(h.id)
        next if h.battler
        frees.push(h)
      end
      free_hex = frees[rand(frees.length)]
      console.log(free_hex.id)
      free_hex.set_battler(damage_event.source)
    end
    gen_subscription_to(@owner, :Died, boink)

  end

end

register_aura(DestabilizingTheRifts)