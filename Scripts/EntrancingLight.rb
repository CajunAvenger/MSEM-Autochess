class EntrancingLight < Aura
  
  def self.get_base_stats
    return {
      :name => "Entrancing Light",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Stunned enemies wander",
      "instead of stop moving.",
      "Gain a Dominion Crown."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    
    @owner.give_artifact(Artifact_DominionCrown.new)

    entrance = Proc.new do |listen, buffer, buff, *args|
      for i in buff.impacts
        i.id = :Wander if i.id == :STUN
      end
    end
    gen_subscription_to(@owner, :Buffing, entrance)
    
  end

end

register_aura(EntrancingLight)