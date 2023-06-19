class SeasonsOfWar < Aura

  def self.get_base_stats
    return {
      :name => "Seasons of War",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Buying Commanders costs",
      "life instead of gold.",
      "Winning a fight with two",
      "or more surviving Soldier",
      "tokens restores health.",
      "Gain a Helena."
    ]
  end

  def self.sprite
    return "Buff"
  end
  
  def extra_init
    # Gain a Helena
    give_unit(Helena)
    
    @owner.blood_units.push(:COMMANDER)
    @owner.storefront.update_sprites if @owner.storefront
    
    win_check = Proc.new do |listen, streak|
      counter = 0
      for u in listen.host.deployed
        counter += 1 if u.is_a?(Commander_Soldier)
      end
      listen.host.gain_life(4)
    end
    gen_subscription_to(@owner, :RoundWon, win_check)

  end
  
  def apply(unit)
    return if @enchanting.include?(unit)
    return unless unit.synergies.include?(:ELDER)
    imps = [
      Impact_new(:POWER_MULTI, -0.2)
    ]
    Buff.new(self, unit, imps)
    @enchanting.push(unit)
  end

end

register_aura(SeasonsOfWar)