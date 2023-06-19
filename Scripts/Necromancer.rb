# Necromancer
# @2/3/4/5
# When one of your units dies, create a skeleton token unit in its place.
# Skeleton stats scale with number of Necromancers.
class Necromancer_Skeleton < Token
  def self.get_base_stats
    return {
      :name       => "Skeleton",
      :cost       => 0,
      :synergy    => [],
      :range      => [1, 1, 1],
      :power      => [10, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [10, 20, 40],
      :archive    => [10, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [300, 20, 40],
      :ability_cost => -1
    }
  end
  
  def get_base(sym)
    b = super(sym)
    sc = 1
    sc = @owner.synergy_handlers[:NECROMANCER].skeleton_scale if @owner
    return sc * b
  end
  
end

class Synergy_Necromancer < Synergy

  def key
    return :NECROMANCER
  end
  
  def breakpoints
    return [2, 3, 4, 5]
  end
  
  def sprite
    return "Necromancer"
  end
  
  def info_text(lv=level)
    return {
      :name => "Necromancer",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "Whenever a non-Skeleton unit~" +
        "dies, create a Skeleton in its place.",
        "33% increased Skeleton stats",
        "66% increased Skeleton stats",
        "100% increased Skeleton stats"
      ],
      :multiblock => {2 => [1], 3 => [1], 4 => [1]},
      :bm => 5,
      :members => @member_names
    }
  end
  
  def deployer
    return true
  end
  
  def init_match_listeners
    return unless level > 0
    skele_bro = Proc.new do |listen, emitter, dead_man, old_hex, damage_event|
      next unless dead_man.owner == @owner
      next if dead_man.is_a?(Necromancer_Skeleton)
      placer = old_hex
      placer = dead_man if !dead_man.dead
      @owner.give_unit(Necromancer_Skeleton.new(), placer)
    end
    gen_subscription_to(@owner.match, :Died, skele_bro)
  end
  
  def skeleton_scale
    return [0, 1, 1.33, 1.66, 2][level]
  end
end
register_synergy(Synergy_Necromancer, :NECROMANCER)