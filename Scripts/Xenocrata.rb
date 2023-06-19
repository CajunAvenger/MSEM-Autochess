class Xenocrata < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Xenocrata",
      :cost       => 4,
      :synergy    => [:COMMANDER, :WIZARD],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [1450, 20, 40],
      :pronoun    => "she/her"
    }
  end
  
  def self.ability_aim
    return [:aggro, 1]
  end
  
  def self.ability_area
    return [:burst, 5]
  end
  
end

module AbilityLibrary
  def ability_script_xenocrata(target_info, mana_cost=@ability_cost)
    target_info[0].delete(@current_hex)
    return unless target_info[0][0]
    for d in target_info[1]
      for h in d[:hexes]
        next if h == @current_hex
        fire = new_animation_sprite
        fire.bitmap = RPG::Cache.icon("Ability/burning_ground.png")
        fire.z = @sprite.z + 35
        fire.x = @sprite.x
        fire.y = @sprite.y
        fire.add_move_to(h.pixel_x, h.pixel_y, d[:dist]*fps/10)
        fire.add_damage(Damage_Ability.new(self, nil, 10*mana_amp), "enemy")
        fire.add_fading(100, 255, 0.5*fps)
        fire.add_wait(5*$frames_per_second, 1)
        fire.add_dispose(1)
      end
    end
    BurningGround.new(self, target_info[0], 50, 5*4)
  end
end

class BurningGround < AoE
  include Timed
  def initialize(source, area, damage, duration)
    @listening_to_me = {}
    @my_listener_cache = []
    @source = source
    @duration = duration
    @area = area
    @damage = damage
    init_timer(:Quarter)
  end
  
  def trigger_effect
    tags = []
    for h in @area
      next unless h.battler
      next unless h.battler.owner != @source.owner
      tags.push(h.battler)
    end
    Damage.new(@source, tags, @damage).resolve
  end
  
  def clear_buff
    clear_listeners()
    @source = nil
    @area = []
    @damage = 0
  end
  
end

register_planeswalker(Xenocrata)
