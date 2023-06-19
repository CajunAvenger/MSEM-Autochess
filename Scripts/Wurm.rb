# Wurm
# @1
# Bessie devours enemies killed, granting permanent increases to all stats.

class Synergy_Wurm < Synergy
  attr_accessor :bessie_cache
  
  def initialize(owner)
    super
  end
  
  def sprite
    return "Wurm"
  end
  
  def key
    return :WURM
  end
  
  def breakpoints
    return [1]
  end
  
  def info_text(lv=level)
    return {
      :name => "Wurm",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "Wurms devour enemies killed,~" +
        "permanently increasing all stats."
      ],
      :bm => 3,
      :members => @member_names
    }
  end
  
  def add_member(member, leech=false)
    super
    bessie_stack = Impact.new(:BessieStack, 0)
    imps = [
      bessie_stack,
      Impact_Linked.new(:POWER, 5, bessie_stack),
      Impact_Linked.new(:MULTI, 1, bessie_stack),
      Impact_Linked.new(:HASTE, 0.05, bessie_stack),
      Impact_Linked.new(:MANA_AMP, 5, bessie_stack),
      Impact_Linked.new(:ARCHIVE, 5, bessie_stack),
      Impact_Linked.new(:TOUGHNESS, 5, bessie_stack),
      Impact_Linked.new(:WARD, 5, bessie_stack),
      Impact_Linked.new(:MAX_LIFE, 10, bessie_stack),
    ]
    bbuff = Buff_Eternal.new(self, member, imps, "All You Can Eat", ["Synergy"])
    nom_nom = Proc.new do |listen, dead_man, old_hex, damage_event|
      next unless listen.subscriber.level
      bbuff.impacts[0].amount += 1
      bbuff.impacts[0].amount += 1 if damage_event.source.empowered.include?(:Brutality)
      for i in 0..4
        nom_spr = new_animation_sprite
        nom_spr.bitmap = RPG::Cache.icon("Synergy/Wurm.png")
        nom_spr.x = dead_man.sprite.x + rand(33) - 16
        nom_spr.y = dead_man.sprite.y + rand(33) - 16
        nom_spr.z = dead_man.sprite.z+11
        nom_spr.opacity = 0
        nom_spr.add_wait(0.1*i*fps)
        nom_spr.add_fade_to(255, 1)
        nom_spr.add_fade_to(0, 0.2*fps)
        nom_spr.add_dispose()
      end
    end
    @member_listeners[member.id] = [gen_subscription_to(member, :Killed, nom_nom)]
  end
end
register_synergy(Synergy_Wurm, :WURM)