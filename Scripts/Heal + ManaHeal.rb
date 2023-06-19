# shortcut for Heal and ManaHeal impacts
class Heal < Impact
  def initialize(amount)
    super(:HEALING, amount)
  end
end

class ManaHeal < Impact
  def initialize(amount)
    super(:MANAGAIN, amount)
  end
end