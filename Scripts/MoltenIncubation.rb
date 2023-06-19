class MoltenIncubation < Aura
  
  def self.get_base_stats
    return {
      :name => "Molten Incubation",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "The fifth time each combat",
      "one of your Draconics cast,",
      "it deals large amounts of",
      "damage to every opponent.",
      "Gain a Boxue."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain an Boxue
    give_unit(Boxue)
    
    @stacks = [-1, 0]
    
    revive = Proc.new do |listen, caster, *args|
      next unless caster.synergies.include?(:DRACONIC)
      if listen.subscriber.stacks[0] != listen.host.match.id
        listen.subscriber.stacks = [listen.host.match.id, 0]
      end
      listen.subscriber.stacks[1] += 1
      if listen.subscriber.stacks[1] == 5
        targs = []
        for u in listen.host.opponent.deployed
          targs.push(u)
          fire = new_animation_sprite
          fire.bitmap = RPG::Cache.icon("Ability/flame.png")
          fire.opacity = 0
          fire.add_stick_to(u.sprite)
          fire.z = u.sprite.z + 40
          fire.add_wait(48, 1)
          fire.add_fade_to(255, 1, 1)
          fire.add_fading(200, 255, 0.1*caster.fps, 0.2*caster.fps, 1)
          fire.add_dispose(1)
        end
        damage = Damage.new(caster, targs, 100)
        egg = new_animation_sprite
        egg.x = caster.sprite.midpoint_x
        egg.y = caster.sprite.midpoint_y
        egg.ox = 32
        egg.oy = 45
        egg.z = caster.sprite.z + 40
        egg.bitmap = RPG::Cache.icon("Auras/egg1.png")
        egg.add_rotation(5, 6)
        egg.add_rotation(-5, 12)
        egg.add_rotation(5, 6)
        egg.add_wait(23, 1)
        egg.add_change_bitmap(RPG::Cache.icon("Auras/egg2.png"), 1)
        egg.add_rotation(5, 6)
        egg.add_rotation(-5, 12)
        egg.add_rotation(5, 6)
        egg.add_wait(23, 1)
        egg.add_change_bitmap(RPG::Cache.icon("Auras/egg3.png"), 1)
        egg.add_damage(damage, "locked")
        egg.add_fade_to(0, 0.2*caster.fps)
        egg.add_dispose
      end
    end
    gen_subscription_to(@owner, :UsedAbility, revive)
  end

end

register_aura(MoltenIncubation)