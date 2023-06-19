# misc Unit effects
class Unit
  
  # quickly generate a generic buff
  def gen_buff(key, target, amount, duration=-1, name="Buff", keys=nil)
    imp = Impact.new(key, amount)
    return Buff.new(self, target, imp, duration, name, keys)
  end
  
  # quickly generate a generic heal event
  def gen_heal(target, amount, duration=1)
    return gen_buff(:HEALING, target, amount, duration, "Heal", ["Heal"])
  end
  
  def drop_artifact(arti_class=nil)
    unless arti_class
      r = rand($artifacts.components.length)
      arti_class = $artifacts.components[r]
    end
    arti_class = get_class(arti_class)
    @opponent.loot(:artifact, arti_class)
  end
  
end