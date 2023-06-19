class TaleOfTwoSons < Aura
  
  def self.get_base_stats
    return {
      :name => "Tale of Two Sons",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "At start of combat, if you",
      "have an open team slot,",
      "gain a copy of your strongest",
      "Mirrorwalker for that combat.",
      "Gain an Ahl."
    ]
  end
  
  def self.sprite
    return "Buff"
  end

  def extra_init
    # Gain an Ahl
    give_unit(Ahl)
    
    @owner.force_deploy = false
    
    mirrored = Proc.new do |listen|
      counter = listen.host.units_allowed
      str = nil
      for u in listen.host.deployed
        next unless u.is_a?(Planeswalker)
        counter -= 1
        if u.synergies.include?(:MIRRORWALKER)
          if !str
            str = u
          else
            str = u if u.damage_dealt > str.damage_dealt
          end
        end
      end
      if counter > 0
        son = str.class.new(str.owner, str.level)
        son.temp = true
        for a in str.artifacts
          son.give_artifact(a.class.new(self))
        end
        listen.host.give_unit(son, str)
        listen.host.deployed.push(son)
      end
    end
    gen_subscription_to(@owner, :Deployed, mirrored)
  end

end

register_aura(TaleOfTwoSons)