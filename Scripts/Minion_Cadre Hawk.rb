class Hawk < Minion
  def self.get_base_stats
    return {
      :name       => "Cadre Hawk",
      :cost       => 1,
      :synergy    => [],
      :range      => [3, 1, 2],
      :power      => [40, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [0.8, 20, 40],
      :mana_amp   => [-1000, 20, 40],
      :archive    => [10, 20, 40],
      :toughness  => [0, 20, 40],
      :ward       => [0, 20, 40],
      :life       => [150, 20, 40],
      :ability_cost => -1
    }
  end
  
  def attack_sprite_file(attack_keys)
    file = "Weapon/claws"
    if attack_keys[:aggro].current_hex.pixel_x > @current_hex.pixel_x
      return file + "_r.png"
    end
    return file + "_l.png"
  end
  
end