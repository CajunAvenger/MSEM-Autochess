class Volta < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Volta",
      :cost       => 3,
      :synergy    => [:ARTIFICER, :CHRONOMANCER, :AKIEVA],
      :range      => [2, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:custom_ward, 1]
  end
  
  def self.ability_area
    return [:custom, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/spider_bot.png"
  end

  def attack_anim_type
    return :spider
  end
  
end

module AbilityLibrary
  def ability_script_volta(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    if @stacks[:volta][1] != @owner.match.id
      # Summon a time golem token with attacks that deal mana-scaling damage.
      # Stun each enemy near the golem.
      golem = Time_Golem.new(@owner, @level)
      efs = Impact.new(:POWER, 40*mana_amp)
      stun_dura = 1
      Buff.new(self, golem, efs)
      @stacks[:volta] = [golem, @owner.match.id]
      @owner.give_unit(golem, target_info[0][0])
      for h in target_info[0]
        next unless h.battler
        next if h.controller == @owner
        Debuff_Timed.new(self, h.battler, Impact.new(:STUN, 1), stun_dura)
      end
    elsif @stacks[:volta][0].dead
      # On recast, if the golem is dead, stun the single enemy nearest Volta.
      stun_dura = 2
      aggro = target_info[0][0].battler
      Debuff_Timed.new(self, aggro, Impact.new(:STUN, 1), stun_dura)
    else
      # On recast, repeat the stun if the golem is still in play.
      for h in target_info[0]
        next unless h.battler
        next if h.controller == @owner
        stun_dura = 1
        Debuff_Timed.new(self, h.battler, Impact.new(:STUN, 1), stun_dura)
      end
    end

  end
  
  def aim_script_volta(range)
    @stacks[:volta] = [nil, nil] unless @stacks[:volta]
    if @stacks[:volta][1] != @owner.match.id
      # summon a time golem on a nearby free hex
      # area_script will stun each in the surrounding area
      areas = @current_hex.get_area_hexes(2)
      free_hex = nil
      for d in areas[1]
        for h in d[:hexes]
          next if h.battler
          return h
          break
        end
      end
    elsif @stacks[:volta][0].dead
      # second+ cast, golem is dead
      # stun enemy nearest to Volta
      return @current_hex.get_closest_enemy
    else
      # second+ cast, golem is alive
      return @stacks[:volta][0].current_hex
    end
  end
  
  def area_script_volta(targetHex, casting_cost=@ability_cost)
    if @stacks[:volta][1] != @owner.match.id
      # stun each in the surrounding area
      return targetHex.get_area_hexes(1)
    elsif @stacks[:volta][0].dead
      # second+ cast, golem is dead
      # stun enemy nearest to Volta
      return [[targetHex], [{:dist => 0 ,:hexes => [targetHex]}]]
    else
      # second+ cast, golem is alive
      return targetHex.get_area_hexes(1)
    end
  end
end

class Time_Golem < Token
  
  def self.get_base_stats
    return {
      :name       => "Time Golem",
      :cost       => 1,
      :synergy    => [],
      :range      => 1,
      :power      => [40, 50, 60],
      :multi      => 10,
      :haste      => 0.7,
      :mana_amp   => 100,
      :archive    => 100,
      :toughness  => 40,
      :ward       => 10,
      :life       => [300, 400, 500],
      :ability_cost => -1
    }
  end

end

register_planeswalker(Volta)
