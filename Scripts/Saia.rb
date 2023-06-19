class Saia < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Saia",
      :cost       => 5,
      :synergy    => [:ELDER, :THESPIAN, :WIZARD],
      :range      => [3, 2, 2],
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
  
  def attack_sprite_file(attack_keys)
    return "Weapon/ice.png"
  end
  
end

module AbilityLibrary
  def ability_script_saia(target_info, mana_cost=@ability_cost)
    dura = 2 * mana_amp
    abil_damage = 100 * mana_amp
    snowflakes = {}
    for h in target_info[0]
      b = h.battler
      sbuff = Debuff_Timed.new(self, b, Impact.new(:STUN, 1), dura)
      snow = new_animation_sprite
      snow.bitmap = RPG::Cache.icon("Ability/snowflake.png")
      snow.add_stick_to(b.sprite)
      snow.z = b.sprite.z + 10
      slow = Proc.new do |target, amount|
        Debuff_Timed.new(self, target, Impact.new(:HASTE_MULTI, -0.33), dura)
      end
      snowflakes[b.id] = snow
      crack = Proc.new do |listen|
        s = snowflakes[listen.host.target.id]
        next unless s
        s.add_wiggles(2, 2, 0.2*fps, 1)
        damage = Damage_Ability.new(self, listen.host.target, abil_damage)
        damage.add_proc(slow)
        s.add_damage(damage, "locked", 1)
        s.add_dispose(1)
      end
      gen_subscription_to(sbuff, :Expired, crack)
    end
  end
  
  def area_script_saia(targetHex, range)
    opps = []
    for u in @owner.opponent.deployed
      hsh = {:unit => u, :ns => []}
      for h in u.current_hex.get_neighbors
        next unless h.battler
        next if h.controller == @owner
        hsh[:ns].push(h.battler)
      end
      opps.push(hsh)
    end
    sorted = opps.sort_by {|hsh| hsh[:ns].length}
    target_limit = 4
    hexes = []
    ns = []
    for s in sorted
      next if ns.include?(s[:unit])
      hexes.push(s[:unit].current_hex)
      break if hexes.length >= target_limit
      ns = ns + s[:ns]
    end
    return [hexes, [{:dist => 0, :hexes => hexes}]]
  end
  
end

register_planeswalker(Saia)
