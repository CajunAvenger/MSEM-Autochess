class AoE < Emitter             # A group of hexes, usually in a circle
  attr_reader :source           # Emitter who created this
  attr_reader :impacter         # Proc that generates new Impacts
  attr_reader :epicenter        # Hex or Unit that this is centered on
  attr_reader :following        # following this unit
  attr_reader :reliant          # Emitter this is reliant on to stay live
  attr_reader :range            # radius of effect
  attr_reader :area             # array of Hexes this affects
  attr_reader :id_number        # AoE's id number
  attr_reader :id               # AoE# id
  attr_reader :keys             # array of keys
  attr_reader :impacting        # map of Unit ids with array of Impacts

=begin
  hsh = {
    :source     => what created this?,
    :epicenter  => what is this centered on?, Hex or Unit
    :range      => range of circle aoe,
    :area       => specific pre-generated area,
    :follow     => follow the epicenter as it moves,
    :reliant    => if this unit dies, clear this AoE,
    :impacter   => Proc that returns array of impacts
  }
=end
  def initialize(hash)
    return AoE_Timed.new(hash) if hash[:duration]
    @listening_to_me = {}
    @my_listener_cache = []
    @id_number = get_aoe_id()
    @id = ("AoE"+@id_number.to_s()).to_sym()

    @source = hash[:source]
    @epicenter = hash[:epicenter]
    @range = hash[:range]
    @area = hash[:area] || []
    @impacter = hash[:impacter]
    @impacting = {}
    @following = nil

    # follow around the epicenter
    if hash[:follow]
      @following = @epicenter
      follow_script = Proc.new do |listen, old_hex, current_hex, path|
        listen.subscriber.recenter
        listen.subscriber.audit_apply
      end
      gen_subscription_to(@epicenter, :Moved, follow_script)
    end
    # disable when the reliant dies
    if hash[:reliant]
      reliant_script = Proc.new do |listen, *args|
        if listen.subscriber.is_a?(Eternal)
          # turn it off for the round
          listen.subscriber.mass_unapply
        else
          # clear the aoe
          listen.subscriber.clear_aoe
        end
      end
      gen_subscription_to(hash[:reliant], :Died, reliant_script)
      # reactivate when the reliant is deployed
      if self.is_a?(Eternal)
        refire_script = Proc.new do |listen|
          listen.subscriber.recenter
          listen.subscriber.audit_apply
        end
        gen_subscription_to(hash[:reliant], :Deployed, refire_script)
        @source.owner.refresh_aoes.push(self)
      end
    end
    match_listener
    recenter if @area.empty?
    audit_apply
  end
  
  def match_listener
    if @match_listen
      @match_listen.clear_listener
    end
    audit = Proc.new do |listen, old_hex, new_hex, path|
      listen.subscriber.audit_apply
    end
    @match_listen = gen_subscription_to(@source.owner.match, :Moved, audit)
  end
  
  # change aoe's epicenter from unit to hex
  def drop_on_hex(hex=nil)
    @following = nil
    hex = @source.current_hex unless hex
    @epicenter = hex
  end
  
  # get new hexes based on epicenter and range
  def recenter
    return unless @range
    if @epicenter.is_a?(Hex)
      @area = @epicenter.get_area_hexes(@range)[0]
    elsif @epicenter.current_hex
      @area = @epicenter.current_hex.get_area_hexes(@range)[0]
    end
  end
  
  # conditions for getting this aoe's impacts
  def applies_to?(unit)
    return true
  end
  
  # apply to members, unapply to ex-members
  def audit_apply
    area_units = []
    all_units = []
    for h in @area
      next unless h.battler
      area_units.push(h.battler)
      all_units.push(h.battler)
    end
    
    for id, hsh in @impacting
      all_units.push(hsh[:unit]) unless area_units.include?(hsh[:unit])
    end
    
    for u in all_units
      applying = @impacting.include?(u.id)
      valid = area_units.include?(u) && applies_to?(u)
      next if applying == valid
      if valid
        apply(u)
      elsif applying
        unapply(u)
      end
    end
  end
  
  # apply impacts to a unit
  def apply(unit)
    return if @impacting.include?(unit.id)
    mini = { :unit => unit, :impacts => [] }
    if @impacter
      mini[:impacts] = @impacter.call(self, unit)
      for i in mini[:impacts]
        i.register(self, unit)
        unit.add_impact(i)
      end
    end
    @impacting[unit.id] = mini
  end
  
  # remove impacts from a unit
  def unapply(unit)
    return unless @impacting.include?(unit.id)
    for i in @impacting[unit.id][:impacts]
      unit.remove_impact(i)
    end
    @impacting.delete(unit.id)
  end
  
  # remove impacts from all units
  def mass_unapply
    for id, stuff in @impacting
      unapply(stuff[:unit])
    end
  end
  
  # kill the AoE
  def clear_aoe()
    emit(:AoeExpired)
    for id, b in @impacting
      unapply(b)
    end
    clear_listeners()
    @area = []
    @source.owner.refresh_aoes.delete(self)
    @source = nil
    @epicenter = nil
    @range = nil
  end
  
end