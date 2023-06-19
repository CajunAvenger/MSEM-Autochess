class Velir < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Velir",
      :cost       => 5,
      :synergy    => [:CONVERGENT, :ELDER, :ALARA],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [10, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [1650, 20, 40],
      :pronoun    => "they/them"
    }
  end
  
  def self.ability_aim
    return [:on_me, 1]
  end
  
  def self.ability_area
    return [:none, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/mray.png"
  end
  
end

module AbilityLibrary
  
  def ability_script_velir(target_info, mana_cost=@ability_cost)
    efs = []
    efs.push(Impact.new(:POWER, 50))
    efs.push(Impact.new(:TOUGHNESS, 50))
    efs.push(Impact.new(:MULTI, 25))
    efs.push(Impact.new(:LIFESTEAL, 0.2))
    vbuff = Buff_Explode.new(self, self, efs, 50, 2, "Maelstrom")
    glowy_spr = new_animation_sprite
    glowy_spr.bitmap = RPG::Cache.icon("Ability/Hexes/light.png")
    glowy_spr.opacity = 128
    glowy_spr.add_stick_to(@sprite)
    glowy_spr.add_fading(64, 128, 0.2*fps, 0, 1)
    glowy_spr.x = @sprite.x
    glowy_spr.y = @sprite.y
    glowy_spr.z = @sprite.z+20
    extend = Proc.new do |listen, *args|
      vbuff.duration += 2*fps
    end
    vbuff.gen_subscription_to(self, :Killed, extend)
    unglow = Proc.new do |listen| 
      g = glowy_spr
      if g && !g.disposed?
        g.dispose
      end
    end
    l = gen_subscription_to(vbuff, :Expired, unglow)
    l.fragile = true
  end
  
end

class Buff_Explode < Buff_Timed
  attr_accessor :boom
  def initialize(source, target, efs, boom, duration, name=nil, keys=nil)
    @boom = boom
    super(source, target, efs, duration, name, keys)
  end
  
  def expire_effect
    abil_damage = @boom * @target.mana_amp
    targ = @target.aggro
    if !targ || targ.dead
      targ = target.get_aggro(@target.get_value(:RANGE), 0)[0]
    end
    if targ
      for i in 0..3
        spr = new_animation_sprite
        spr.bitmap = RPG::Cache.icon("Ability/light_bolt.png")
        spr.x = targ.sprite.x
        spr.y = targ.sprite.y
        spr.z = targ.sprite.z+20
        spr.add_orbit(targ.sprite, 32, 0.4*fps, 32, Math::PI*i/2, -1)
        spr.add_damage(Damage_Ability.new(@target, targ, abil_damage)) if i == 0
        spr.add_dispose
      end
    end
    emit(:Expired)
  end
  
  def clone_args(new_target, new_efs)
    return [
      Buff_Explode,
      [@source, new_target, new_efs, @boom, @name, @keys],
      [
        ["counter", @counter],
        ["board_sprite", (@board_sprite ? @board_sprite.create_clone(@target, new_target) : nil)]
      ]
    ]
  end
  
end
register_planeswalker(Velir)