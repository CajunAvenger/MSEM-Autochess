class RightToRule < Aura

  def self.get_base_stats
    return {
      :name => "Right to Rule",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "The first time each combat",
      "your Tzhais would die, he",
      "becomes invulnerable for",
      "several seconds, and heals",
      "for each kill he scores",
      "in that duration.",
      "Gain a Tzhai."
    ]
  end

  def self.sprite
    return "WalkerSpecial"
  end
  
  def extra_init

    give_unit(Tzhai)
    
    deus = Proc.new do |listen, unit, *args|
      next unless unit.name == "Tzhai"
      next if @frames[unit.id] && @frames[unit.id] == listen.host.match.id
      @frames[unit.id] = listen.host.match.id
      imps = [
        Impact.new(:INVULNERABLE, 1),
        Impact.new(:LGOK, 50)
      ]
      Buff_Timed.new(self, unit, imps, 4)
      unit.current_damage = unit.get_value(:MAX_LIFE) - 1
    end
    gen_subscription_to(@owner, :Dying, deus)
  end

end

register_aura(RightToRule)