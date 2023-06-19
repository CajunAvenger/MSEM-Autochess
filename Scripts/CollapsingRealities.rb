class CollapsingRealities < Aura
  
  def self.get_base_stats
    return {
      :name => "Collapsing Realities",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Stunned enemies also take",
      "damage over time,",
      "increasing as combat goes on.",
      "Gain an Aerida."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain an Aerida
    give_unit(Aerida)

    dot = Proc.new do |listen, buffer, buff, *args|
      valid = false
      for i in buff.impacts
        valid = true if i.id == :STUN
      end
      next unless valid
      dm = 100 * listen.host.match.combat_frames / listen.host.match.max_combat_frames
      DoT.new(buffer, buff.target, dm*buff.duration, buff.duration)
    end
    gen_subscription_to(@owner, :Buffing, dot)
  end

end

register_aura(CollapsingRealities)