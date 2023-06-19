# Damage from a basic attack
class Damage_Attack < Damage
end

# Damage from an ability proc
class Damage_Ability < Damage
end
# Damage from a buff, eg Poison
class Damage_Buff < Damage
end

class Damage_True < Damage
  def initialize(source, target, amount, lifesteal=0, keys = nil)
    super(targets, source, 0, amount, lifesteal, keys = nil)
  end
end