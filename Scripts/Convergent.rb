# Convergent
# @3
# The first time each round you buy a planeswalker
# you don't own another copy of, refill that store space.
# @5
# Each of your Convergent gets a unique benefit.
# Mabil: Large amount of mana amp.
# Menna: First attack against a target deals greatly increased damage.
# Sadie: Large amount of archive.
# Velir: Increases all stats.
# Glitch: Casts spell immediately on start of combat.
class Synergy_Convergent < Synergy
  attr_accessor :refilled
  attr_accessor :mennas
  
  def key
    return :CONVERGENT
  end
  
  def breakpoints
    return [3, 5]
  end
  
  def sprite
    return "Convergent"
  end
  
  def info_text(lv=level)
    return {
      :name => "Convergent",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "The first time each round you~" +
        "buy a planeswalker you didn't~" +
        "own yet, refill its store spot.",
        "Convergents get unique benefits:~" +
        "Menna: First attack vs targets~" +
        "deal increased damage.~" +
        "Mabil: +100 mana amp.~" +
        "Sadie: +100 archive.~" +
        "Velir: Increase all stats.~" +
        "Glitch: Casts at start of combat."
      ],
      :bm => "10",
      :multiblock => {2 => [1]},
      :members => @member_names
    }
  end
  
  def initialize(owner)
    super
    @refilled = false
    @mennas = {}
    # first time you buy a unique walker each round, restock that store space
    restock = Proc.new do |listen, unit|
      next unless listen.subscriber.level > 0
      next if listen.subscriber.refilled
      if listen.host.unit_counts(unit.name) == 1
        listen.subscriber.refilled = true
        listen.host.storefront.restock(1)
      end
    end
    gen_subscription_to(@owner, :UnitBought, restock)
  end
  
  def deployer
    return true
  end
  
  def round_reset
    # reset our refilled status at round end
    @refilled = false
    @mennas = {}
  end
  
  def init_match_listeners
    # top off Glitch and fire up Menna
    if level > 1
      for u in @owner.deployed
        if u.name == "Glitch"
          u.mana = 200.0
          u.update_mana
        elsif u.name == "Menna"
          uid = u.id
          @mennas[uid] = []
          dragonfire = Proc.new do |listen, attack_keys|
            next if listen.subscriber.mennas[uid].include?(attack_keys[:aggro].id)
            listen.subscriber.mennas[uid].push(attack_keys[:aggro].id)
            attack_keys[:extra_p] = 40
            tsprite = attack_keys[:aggro].sprite
            flame = new_animation_sprite
            flame.bitmap = RPG::Cache.icon("Ability/flame.png")
            flame.x = tsprite.x
            flame.y = tsprite.y
            flame.z = tsprite.z + 15
            flame.opacity = 0
            flame.add_wait(0.2*fps)
            flame.add_fade_to(224, 0.1*fps)
            flame.add_fade_to(0, 0.2*fps)
            flame.add_dispose
          end
          gen_subscription_to(u, :Attacking, dragonfire)
        end
      end
    end
  end
  
  def add_member(member, leech=false)
    super
    case member.name
    when "Mabil"
      imp = Impact_SynLimit.new(:MANA_AMP, 100, self, 2)
      Buff_Eternal.new(self, member, [imp], "Mabil's Ascension", ["Synergy"])
    when "Sadie"
      imp = Impact_SynLimit.new(:ARCHIVE, 100, self, 2)
      Buff_Eternal.new(self, member, [imp], "Sadie's Ascension", ["Synergy"])
    when "Velir"
      imp = []
      imp.push(Impact_SynLimit.new(:POWER, 30, self, 2))
      imp.push(Impact_SynLimit.new(:MULTI, 30, self, 2))
      imp.push(Impact_SynLimit.new(:HASTE, 0.2, self, 2))
      imp.push(Impact_SynLimit.new(:MANA_AMP, 30, self, 2))
      imp.push(Impact_SynLimit.new(:ARCHIVE, 30, self, 2))
      imp.push(Impact_SynLimit.new(:TOUGHNESS, 30, self, 2))
      imp.push(Impact_SynLimit.new(:WARD, 30, self, 2))
      imp.push(Impact_SynLimit.new(:MAX_LIFE, 30, self, 2))
      imp.push(Impact_SynLimit.new(:RANGE, 1, self, 2))
      Buff_Eternal.new(self, member, imp, "Velir's Ascension", ["Synergy"])
    end
  end
  
  def buff_visible?(buff)
   return level() > 1
 end
 
end
register_synergy(Synergy_Convergent, :CONVERGENT)