class Mannequin < Minion
  def self.get_base_stats
    return {
      :name       => "Mannequin",
      :cost       => 1,
      :synergy    => [],
      :range      => [1, 1, 2],
      :power      => [20, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [0.8, 20, 40],
      :mana_amp   => [10, 20, 40],
      :archive    => [-100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [250, 20, 40]
    }
  end
end