class Artifact_LampOfEndlessPossibilities < Artifact

  def self.get_base_stats
    return {
      :name       => "Lamp of Endless Possibilities",
      :description => "Grants power and mana amp. Spells have increased cooldown, " +
        "but can multistrike.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:POWER, 10]],
        [Impact, [:MANA_AMP, 10]],
        [Impact, [:MAX_MANA, 40]]
      ],
      :components => ["Seishin's Edge", "Iron Signet"],
      :back   => [:POWER, :MANA_AMP]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants power and ward. Spells",
      "have increased cooldown, but can",
      "multistrike."
    ]
  end
  
  def equip_to(target)
    super
    copy = Proc.new do |listen, cost, iter|
      next if iter.include?(@id)
      r = rand(50)
      next unless r < target.get_value(:MULTI)
      iter.push(@id)
      target.try_ability(target.name, 0, iter)
    end
    @equip_listen = gen_subscription_to(target, :UsedAbility, copy)
    @wielder.ability_cost += 40
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_LampOfEndlessPossibilities)