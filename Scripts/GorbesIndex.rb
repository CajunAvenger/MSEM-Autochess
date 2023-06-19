class GorbesIndex < Aura
  attr_accessor :index
  def self.get_base_stats
    return {
      :name => "Gorbes Index",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your lowest-cost Wizard starts",
      "combat indexed with large amounts",
      "of archive. When your indexed unit",
      "casts, the index advances to",
      "the next higher cost Wizard.",
      "Gain an Arina."
    ]
  end

  def self.sprite
    return "Buff"
  end
  
  def extra_init
    # Gain an Arina
    give_unit(Arina)
       
    @index = nil
    
    kick_off = Proc.new do |listen|
      listen.subscriber.indexer
    end
    gen_subscription_to(@owner, :Deployed, kick_off)
    
  end
  
  def indexer(min_val=0)
    @index.clear_buff if @index
    hold = nil
    for u in @owner.deployed
      next unless u.synergies.include?(:WIZARD)
      next unless u.cost > min_val
      if hold
        hold = u if u.cost < hold.cost
      else
        hold = u
      end
    end
    return unless hold
    @index = Buff.new(self, hold, Impact.new(:ARCHIVE, ind_val))
    book_sprite = new_animation_sprite
    book_sprite.bitmap = RPG::Cache.icon("Auras/index.png")
    book_sprite.z = hold.sprite.z+30
    book_sprite.add_stick_to(hold.sprite)
    b.board_sprite = book_sprite
    mid = @owner.match.id
    advancer = Proc.new do |listen, *args|
      next unless listen.host.owner.match.id == mid
      listen.subscriber.indexer(listen.host.cost)
    end
    gen_subscription_to(hold, :UsedAbility, advancer)
    l.fragile = true
  end

end

register_aura(GorbesIndex)