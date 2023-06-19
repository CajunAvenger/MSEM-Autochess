# A Synergy object manages all Units within a Synergy
# When a Unit enters, it becomes a member of the Synergy
# The Synergy then subscribes to the relevant emits of that Unit
#  and subscribes the Unit with the relevant responses
# On creation, the Synergy may subscribe to Game for particular emits
# Synergy fields the main emit, then determines if it matters for each subscriber
#  then emits to the relevant ones
# Synergies can affect non-member emitters, but it has to do that via Game emits
# For example, Shaharazad-2 gives all your planeswalkers a one-time death save
class Synergy < Emitter
  attr_reader :id
  attr_reader :owner            # owner of this handler
  attr_reader :members          # each member being affected
  attr_reader :member_names     # unique names for breakpoints
  attr_accessor :extra_counter  # count as having extra members
  attr_accessor :trigger_cache  # allow triggers to store data here
  attr_accessor :match_listeners# listeners to be cleared at end of match
  attr_accessor :member_listeners # listeners to be cleared when a member is removed
  attr_accessor :impacting      # units with blanketer impacts 
  def initialize(owner)
    @listening_to_me = {}
    @my_listener_cache = []
    @owner = owner
    @members = []
    @member_names = []
    @extra_counter = 0
    @trigger_cache = {}
    @id = "Synergy"
    @match_listeners = []
    @member_listeners = {}
    @impacting = {}
    
    if deployer() && @owner
      on_deploy = Proc.new do |listen|
        listen.subscriber.init_match_listeners
      end
      gen_subscription_to(@owner, :Deployed, on_deploy)
      on_done = Proc.new do |listen, streak|
        for l in listen.subscriber.match_listeners
          l.clear_listener if l
        end
        listen.subscriber.match_listeners = []
      end
      gen_subscription_to(@owner, :RoundEnd, on_done)
    end
    
  end
  
  def key
    return :KEY
  end
  
  def deployer
    return false
  end
  
  def blanketer
    return false
  end
  
  def apply(unit)
  end
  
  def check_levels
  end
  
  def breakpoints
    return [1]
  end
  
  def round_reset
  end
  
  def sprite
    return "syn_default"
  end
  
  def info_text(lv=level)
    return {
      :name => "Default",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "This ain't got no members"
      ],
      :members => @member_names
    }
  end
  
  def has_infobox?
    return true
  end
  
  def write_to_infobox(infobox, tn=nil)
    info = info_text(test_level(tn))
    highlights = []
    blocks = []
    text = info[:name]
    if info[:header]
    block_text = info[:header].split("~")
      for b in block_text
        blocks.push(b)
        highlights.push(0)
      end
    end

    if info[:blocks].is_a?(Hash)
      for key, line in info[:blocks]
        block_text = key + ": " + line
        block_text = block_text.split("~")
        for bt in block_text
        blocks.push(bt)
        end
        hi = 0
        hi = 1 if info[:members].include?(key)
        for bt in block_text
        highlights.push(hi)
        end
        text += hi.to_s + line + hi.to_s
      end
    else
      for i in 0..info[:blocks].length-1
        block_text = info[:breaks][i].to_s + ": " + info[:blocks][i]
        block_text = block_text.split("~")
        for bt in block_text
        blocks.push(bt)
        end
        hi = 0
        hi = 1 if i+1 == info[:level]
        if info[:multiblock] && info[:multiblock][info[:level]]
        hi = 1 if info[:multiblock][info[:level]].include?(i+1)
        end
        for bt in block_text
        highlights.push(hi)
        end
        text += hi.to_s + info[:blocks][i] + hi.to_s
      end
    end
    
    if text != infobox.cached_text
      infobox.submenu = nil
      bm = "Graphics/Icons/Infobox.png"
      bm = "Graphics/Icons/Infobox_" + info[:bm].to_s + ".png" if info[:bm]
      infobox.bitmap = Bitmap.new(bm)
      infobox.bitmap.font.name = "Fontin"
      infobox.bitmap.font.size = 17
      infobox.bitmap.font.color.set(255,255,255)
      title = info[:name]
      infobox.bitmap.draw_text(10, 6, 128, 24, info[:name])
      
      x_start = infobox.bitmap.width - 20 - 24 * (info[:breaks].length-1)
      for b in 0..info[:breaks].length-1
        infobox.bitmap.font.color.set(255,255,0) if b+1 == info[:level]
        infobox.bitmap.draw_text(x_start, 6, 40, 24, info[:breaks][b].to_s)
        infobox.bitmap.font.color.set(255,255,255)
        infobox.bitmap.draw_text(x_start+7, 6, 128, 24, " •") unless b == info[:breaks].length-1
        x_start += 24
      end
  
      y_start = 30
      
      for b in 0..blocks.length-1
        infobox.bitmap.font.color.set(255,255,0) if highlights[b] == 1
        infobox.bitmap.draw_text(10, y_start, 256, 24, blocks[b])
        y_start += 20
        infobox.bitmap.font.color.set(255,255,255)
      end
      
      infobox.cached_text = text
    end
    if infobox.subsprites.length > 0 && infobox.subsprites[0].holder != sprite()
      for s in infobox.subsprites
        s.dispose
      end
      infobox.subsprites = []
    end
    if infobox.subsprites.length == 0
      for id, m in @owner.units
        next if m.dead
        next unless m.synergies.include?(key())
        hi = new_hex_sprite
        hi.bitmap = RPG::Cache.icon("Synergy/"+sprite()+".png")
        hi.holder = sprite()
        hi.add_stick_to(m.sprite, 0, 8, 6)
        hi.add_fading(200, 255, 0.4*$frames_per_second, 0, 1)
        hi.z = 9000
        infobox.subsprites.push(hi)
      end
    end
  end
  
  def level(mc=nil)
    lv = 0
    mc = member_count() unless mc
    for b in breakpoints()
      lv += 1 if b <= mc
    end
    return lv
  end
  
  def test_level(mem=nil)
    mc = member_count()
    mc += 1 if mem != nil && !@member_names.include?(mem)
    return level(mc)
  end
  
  def init_match_listeners
    # not all synergies will need to do this but they can do so here
  end
  
  def clear_match_listeners
    for l in @match_listeners
      l.clear_listener
    end
  end
  
  def add_member(member, leech=false)
    return false if @members.include?(member)
    # almost all synergies will need unique setups here
    @members.push(member)
    unless leech || @member_names.include?(member.name)
      @member_names.push(member.name)
    end
    emit(:NewMember, member)
    return true
  end
  
  def remove_member(ex_member)
    # remove from members
    return false unless @members.include?(ex_member)
    @members.delete(ex_member)
    @member_names.delete(ex_member.name)
    for m in @members
      @member_names.push(m.name) unless @member_names.include?(m.name)
    end
    if @member_listeners[ex_member.id]
      for l in @member_listeners[ex_member.id]
        l.clear_listener
      end
    end
    emit(:LostMember, ex_member)
    return true
  end
  
  def member_count
    return @member_names.length + @extra_counter
  end
  
  def buff_visible?(buff)
    return level() > 0
  end
  
  def has_innate?
    return false
  end
  
  def show_icon
    return @member_names.length > 0
  end
  
  def match_apply(unit)
    
  end

end