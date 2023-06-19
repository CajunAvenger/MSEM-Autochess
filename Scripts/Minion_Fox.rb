class Fox < Minion
  def self.get_base_stats
    return {
      :name       => "Fox",
      :cost       => 3,
      :synergy    => [],
      :range      => [1, 1, 2],
      :power      => [40, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [0.8, 0.8, 0.8],
      :mana_amp   => [10, 20, 40],
      :archive    => [10, 20, 40],
      :toughness  => [50, 20, 40],
      :ward       => [25, 20, 40],
      :life       => [200, 400, 1200],
      :ability_cost => -1
    }
  end
end