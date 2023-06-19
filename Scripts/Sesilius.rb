class Sesilius < Planeswalker

  def self.get_base_stats
    return {
      :name       => "Sesilius",
      :cost       => 4,
      :synergy    => [:AKIEVA, :NECROMANCER],
      :range      => [1, 2, 2],
      :power      => [50, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [100, 20, 40],
      :archive    => [100, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [450, 20, 40],
      :pronoun    => "he/him"
    }
  end
  
  def self.ability_aim
    return [:aggro, 3]
  end
  
  def self.ability_area
    return [:aggro, 1]
  end
  
  def attack_sprite_file(attack_keys)
    return "Weapon/pray.png"
  end
  
end

module AbilityLibrary
  def ability_script_sesilius(target_info, mana_cost=@ability_cost)
    aggro = target_info[0][0].battler
    return unless aggro
    scale = 50 * mana_amp
    imps = [
      Impact.new(:CONFUSED, 1)
    ]
    db = Debuff_Timed.new(self, aggro, imps, 6)
    conf = new_animation_sprite
    conf.bitmap = RPG::Cache.icon("confused.png")
    conf.add_stick_to(aggro.sprite)
    conf.z = aggro.sprite.z + 20
    db.board_sprite = conf
    bonus = Proc.new do |listen, attack_keys|
      if attack_keys[:aggro].owner == listen.host.owner
        attack_keys[:extra_p] += scale
      end
    end
    db.gen_subscription_to(aggro, :Attacking, bonus)
  end
end

register_planeswalker(Sesilius)
