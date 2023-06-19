def gen_invulnerable_buff(source, target, duration, name="Invulnerable", keys=nil)
  inv = Impact.new(:INVULNERABLE, 1)
  return Buff_Timed.new(source, target, inv, duration, name, keys)
end