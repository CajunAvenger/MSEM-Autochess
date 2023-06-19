class Artifact_HelmOfPrinces < Artifact

  def self.get_base_stats
    return {
      :name       => "Helm of Princes",
      :description => "Grants archive ward. Wielder's spell charges whenever " +
        "ward causes an enemy's spell to be delayed.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Wand"],
      :impacts    => [
        [Impact, [:ARCHIVE, 10]],
        [Impact, [:WARD, 10]],
        [Impact, [:MANA_AMP, 0]]
      ],
      :components => ["Warded Tome", "Mageweave Cloak"],
      :back   => [:ARCHIVE, :WARD]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants archive and ward. Wielder's",
      "spellcharges whenever ward causes",
      "an enemy's spell to be delayed."
    ]
  end
  
  def equip_to(target)
    super
    # Proc that recharges depening on ward value
    # triggers whenever any unit has a spell delayed
    ward_checker = Proc.new do |listen, caster, warded|
      next if listen.subscriber.wielder.dead
      listen.subscriber.wielder.apply_mana_heal(ManaHeal.new(warded))
      sparkles = new_animation_sprite
      sparkles.bitmap = RPG::Cache.icon("sparkles.png")
      sparkles.center_on(caster.sprite)
      sparkles.z = listen.subscriber.wielder.sprite.z + 30
      sparkles.add_slide_to(listen.subscriber.wielder.sprite, 0.5*listen.subscriber.wielder.fps)
      sparkles.add_dispose
    end
    
    # Proc that sets up the ward checker for each match
    # triggers whenever the player deploys
    stacker = Proc.new do |listen|
      listen.subscriber.gen_subscription_to(listen.host.opponent, :Warded, ward_checker)
    end
    @equip_listener = gen_subscription_to(target.owner, :Deployed, stacker)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listener.clear_listener
    if @dreaming_listen
      @dreaming_listen.clear_listener
      @dreaming_listen = nil
      @dreaming_listen2.clear_listener
      @dreaming_listen2 = nil
    end
    @impacts[2].amount = 0
    super
  end
  
  def dream_up
    @empowered.push(:dreaming) unless @empowered.include?(:dreaming)
    return if @dreaming_listen
    stacker2 = Proc.new do |listen, *args|
      listen.subscriber.impacts[2].amount += 10
    end
    @dreaming_listen = gen_subscription_to(@wielder, :Warded, stacker2)
    unstacker = Proc.new do |listen, *args|
      listen.subscriber.impacts[2].amount = 0
    end
    @dreaming_listen2 = gen_subscription_to(@wielder.owner, :RoundResolved, unstacker)
  end
  
end

register_artifact(Artifact_HelmOfPrinces)