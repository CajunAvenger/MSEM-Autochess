class PerfectDistraction < Aura
  
  def self.get_base_stats
    return {
      :name => "Perfect Distraction",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Cats taunt enemies",
      "they move past and reduce",
      "those enemies' attack power.",
      "Gain an Eve."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain an Eve
    give_unit(Eve)
    
    # Apply to existing Cats
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Cats
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:CAT)
    taunt = Proc.new do |listen, old_hex, current_hex, path|
      next unless $processor_status == :combat_phase
      ns = current_hex.get_neighbors
      ih = []
      if ns.include?(old_hex)
        # If these hexes are neighbors, debuff their common neighbors
        ih = old_hex.get_neighbors & ns
      elsif path
        # If there's a path cache, debuff the neighbors of the intermediate hexes
        for id in path
          next if id == current_hex.id
          next if id == old_hex.id
          ih.push(@owner.match.board.board_map[id])
        end
        # If neither, dash path
      end
      for hex in ih
        next unless hex.battler
        next if hex.battler.owner == @owner
        imps = [
          Impact.new(:TAUNT, 1, listen.host, listen.host),
          Impact.new(:POWER, -30)
        ]
        Debuff_Timed.new(listen.host, hex.battler, imps, 3)
      end
    end
    gen_subscription_to(unit, :Moved, taunt)
    @enchanting.push(unit)
  end

end

register_aura(PerfectDistraction)