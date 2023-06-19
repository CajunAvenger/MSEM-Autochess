class Certo < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Certo",
      :cost       => 2,
      :synergy    => [:CAT, :WIZARD],
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
    return [:aggro, 1]
  end
  
  def self.ability_area
    return [:cone, 2]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/lray.png"
  end
  
end

module AbilityLibrary
 
  def ability_script_certo(target_info, mana_cost=@ability_cost)
    return unless target_info[0][0]
    abil_damage = 100 * mana_amp
    @stacks[:certo] = [nil, nil] unless @stacks[:certo]
    if @stacks[:certo][1] == @owner.match.id
      # stack up
      @stacks[:certo][0] += 1
    else
      # restart
      @stacks[:certo] = [1, @owner.match.id]
    end
    angler = {
      :right => 0,
      :top_right => 30,
      :top => 90,
      :top_left => 150,
      :left => 180,
      :bottom_left => 210,
      :bottom => 270,
      :bottom_right => 330
    }
    angle = angler[target_info[3]]
    cone = new_animation_sprite
    cone.bitmap = RPG::Cache.icon("Ability/certo_cone.png")
    cone.center_on(@sprite)
    cone.ox = 0
    cone.oy = cone.center_y
    cone.angle = angle
    cone.z = @sprite.z + 25
    cone.add_fade_to(0, 0.5*fps)
    cone.add_dispose
    targets = []
    for h in target_info[0]
      next unless h.battler
      next unless h.controller != @owner
      targets.push(h.battler)
    end
    Damage_Ability.new(self, targets, abil_damage).resolve()
    nearby = @current_hex.get_area_hexes(1)
    for n in nearby[0]
      next unless n.battler
      next unless n.battler.owner == @owner
      cbuff = Buff_Timed.new(self, n.battler, Impact.new(:MULTI, 10*@stacks[:certo][0]), 5)
      ms_sprite = new_animation_sprite
      ms_sprite.bitmap = RPG::Cache.icon("multi.png")
      ms_sprite.z = @sprite.z + 30
      ms_sprite.add_orbit(n.battler.sprite, 32, 32, 0)
      cbuff.board_sprite = ms_sprite
    end
  end
end

register_planeswalker(Certo)
