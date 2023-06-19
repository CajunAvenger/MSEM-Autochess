class FleetingMoments < Aura
  
  def self.get_base_stats
    return {
      :name => "Fleeting Moments",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Your Chronomancers gain",
      "increased archive, and",
      "enemies stunned by them",
      "lose spell charge.",
      "Gain an Aerida."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def enchants
    return :unit
  end

  def extra_init
    # Gain a Aerida
    give_unit(Aerida)
    
    # Apply to existing Chronomancers
    for id, u in @owner.units
      apply(u)
    end
    
    # Set up listener to apply to future Chronomancers
    futureproof = Proc.new do |listen, unit|
      apply(unit)
    end
    gen_subscription_to(@owner, :Summoned, futureproof)
    
    heavy_stun = Proc.new do |listen, buffer, buff|
      next unless buffer.synergies.include?(:CHRONOMANCER)
      valid = false
      for i in buff.impacts
        valid = true if i.id == :STUN
      end
      next unless valid
      buff.target.mana *= 0.8
      buff.target.update_mana
    end
    gen_subscription_to(@owner, :Buffing, heavy_stun)

  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:CHRONOMANCER)
    imps = [
      Impact.new(:ARCHIVE_MULTI, 0.2),
    ]
    Buff_Eternal.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(FleetingMoments)