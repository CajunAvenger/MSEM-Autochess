class Artifact_TomeOfLoss < Artifact
  attr_accessor :stacks
  def self.get_base_stats
    return {
      :name       => "Tome of Loss",
      :description => "The first time the wielder dies each combat, it and " +
        "another dead planeswalker with the same cost are revived.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Trinket"],
      :impacts    => [],
      :back   => [:UNIQUE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "The first time the wielder dies",
      "each combat, it and another dead",
      "planeswalker ally with the same",
      "cost are revived."
    ]
  end
  
  def equip_to(target)
    super
    revive = Proc.new do |listen, buff|
      next if listen.subscriber.stacks == listen.host.owner.match.id
      listen.subscriber.stacks = listen.host.owner.match.id
      listen.host.current_damage = 0
      for u in listen.host.owner.match.board.graveyard
        next unless u.owner == listen.host.owner
        next unless u.cost == listen.host.cost
        fh = listen.host.current_hex.get_closest_empty
        u.current_damage = 0
        u.update_life
        u.dead = false
        u.emit(:Revived, self)
        fh.set_battler(u)
        listen.host.owner.deployed.push(u)
        u.sprite.add_fade_to(255, 0.4*u.fps, u.sprite.add_schedule)
        
        book = new_animation_sprite
        book.bitmap = RPG::Cache.icon("Tome/closed.png")
        book.center_on(listen.host.sprite)
        book.z = 7000
        book.add_wait(0.2*$frames_per_second)
        book.add_change_bitmap(RPG::Cache.icon("Tome/open.png"))
        book.add_wait(0.7*$frames_per_second)
        book.add_dispose
        
        skull = new_animation_sprite
        skull.bitmap = RPG::Cache.icon("Tome/skull.png")
        skull.opacity = 0
        skull.center_on(listen.host.sprite)
        skull.y += 30
        skull.z = 7000
        skull.add_wait(0.2*$frames_per_second)
        skull.add_wait(0.2*$frames_per_second, 1)
        skull.add_wait(0.2*$frames_per_second, 2)
        skull.add_fade_to(255, 0.4*$frames_per_second)
        skull.add_translate(0, -30, 0.4*$frames_per_second, 1)
        #skull.add_wiggles(4, 4, 0, 2)
        skull.add_dispose
        break
      end
    end
    @equip_listener = gen_subscription_to(@wielder, :Dying, revive)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listener.clear_listener
    super
  end
  
end

register_artifact(Artifact_TomeOfLoss)