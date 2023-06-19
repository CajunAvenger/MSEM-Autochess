class Helena < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Helena",
      :cost       => 2,
      :synergy    => [:CLERIC, :COMMANDER, :AERIAL],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:around_me, 1]
  end
  
  def self.ability_area
    return [:custom, 1]
  end
  
end

module AbilityLibrary
  
  def area_script_helena(targetHex, range)
    return targetHex.get_area_hexes(range) unless @stacks[:helena] == @owner.match.id
    ag_info = get_aggro(1, 0)
    return nil unless ag_info[0]
    targetHex = ag_info[0].current_hex
    return [[targetHex], [{:dist => 0, :hexes => [targetHex]}]]
  end
  
  def ability_script_helena(target_info, mana_cost=@ability_cost)
    @stacks[:helena] = nil unless @stacks[:helena]
    if @stacks[:helena] != @owner.match.id
      # buff self on first cast
      @stacks[:helena] = @owner.match.id
      imp = 100 * mana_amp
      imps = [
        Impact.new(:POWER, imp),
        Impact.new(:TOUGHNESS, imp),
      ]
      Buff.new(self, self, imps, "Faradia's Grace")
      for h in target_info[0]
        next unless h.battler
        next if h.controller == @owner
        Debuff_Timed.new(self, h.battler, Impact.new(:STUN, 1), 2)
      end
    else
      # stun if we're already buffed
      tag = target_info[0][0].battler
      Debuff_Timed.new(self, tag, Impact.new(:STUN, 1), 4)
      abil_damage = 2 * get_value(:POWER)
      Damage_Ability.new(self, tag, abil_damage).resolve()
    end
  end
end

register_planeswalker(Helena)