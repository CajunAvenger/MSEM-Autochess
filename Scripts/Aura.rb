# An Aura applied to a player
class Aura < Emitter
  attr_reader :name             # the name of the Aura
  attr_reader :owner            # the owner of this Aura
  attr_reader :id_number        # Aura's id#
  attr_reader :id               # Aura's id
  attr_reader :tier             # Aura's tier
  attr_accessor :active         # is the Aura active or disabled?
  attr_accessor :enchanting     # array of objects this has been applied to
  attr_accessor :frames         # array of objects this has been applied to
  attr_accessor :stacks
  def self.get_base_stats
    return {
      :name => "Unnamed",
      :tier  => 1
    }
  end
  
  def self.get_description
    return ["Someone forgot to give this a description."]
  end
  
  def self.sprite
    return "Board"
  end
  
  def enchants
    return nil
  end

  def get_description
    return self.class.get_description
  end
  
  def sprite
    return self.class.sprite
  end
  
  def initialize(owner)
    inherent = self.class.get_base_stats
    @listening_to_me = {}
    @my_listener_cache = []
    @owner = owner
    @name = inherent[:name] || "Unnamed"
    @tier = inherent[:tier] || 1
    @active = true
    @id_number = get_aura_id()
    @enchanting = []
    @frames = {}
    @stacks = []

    @id = @name + @id_number.to_s
    # by default we don't set up a listener or apply impacts
    # many Auras will want to to do so in extra_init though
    extra_init
  end
  
  def extra_init
  end
  
  def self.can_be_given_to?(player)
    return 0 if player.auras.any?(self)
    return 1
  end
  
  # kill the Aura
  def clear_aura()
    clear_listeners()
    @owner = nil
    @source = nil
    @impacting = nil
  end
  
  def has_infobox?
    return true
  end
  
  def write_to_infobox(infobox, extra=nil)
    text = @name

    if text != infobox.cached_text
      infobox.cached_text = text
      infobox.submenu = nil
      desc = get_description
      infobox.bitmap = Bitmap.new("Graphics/Icons/Infobox_"+desc.length.cap(8).to_s+".png")
      infobox.bitmap.font.name = "Fontin"
      infobox.bitmap.font.size = 17
      infobox.bitmap.font.color.set(255,255,255)
      infobox.bitmap.draw_text(10, 6, 256, 24, @name)
      
      y_start = 30

      for d in desc
        infobox.bitmap.draw_text(10, y_start, 256, 24, d)
        y_start += 20
      end

    end
  end
  
  def apply(ap)
  end
  
  def give_walker(cname, level=1)
    unit = cname.new(@owner, level)
    $walker_pool.try_remove(unit.name)
    @owner.give_unit(unit)
    return unit
  end
  
  def give_walker_with(cname, aname)
    unit = cname.new(@owner)
    arti = aname.new(self)
    unit.give_artifact(arti)
    $walker_pool.try_remove(unit.name)
    @owner.give_unit(unit)
    return unit
  end
  
  def give_walker_and(cname, aname)
    unit = cname.new(@owner)
    @owner.give_artifact(aname.new)
    $walker_pool.try_remove(unit.name)
    @owner.give_unit(unit)
    return unit
  end
  
  alias give_unit give_walker
  alias give_unit_with give_walker_with
  alias give_unit_and give_walker_and
  
end

module Enchantable
end