class Artifact_HimitsuShiguresLegacy < Artifact

  def self.get_base_stats
    return {
      :name       => "Himitsu, Shigure's Legacy",
      :description => "Grants haste and archive. Also reduces spell cooldown " +
        "further every time an attack hits, and reduces action-delay " +
        "after casting to 0.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Sword"],
      :impacts    => [
        [Impact, [:HASTE_MULTI, 0.1]],
        [Impact, [:ARCHIVE, 10]]
      ],
      :components => ["Cinderblade", "Warded Tome"],
      :back   => [:HASTE, :ARCHIVE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
     "Grants haste and archive. Also",
     "reduces spell cooldown further",
     "every time an attack hits."
    ]
  end
  
  def equip_to(target)
    super
    free_money = Proc.new do |listen, attack_keys, i|
      listen.host.ability_cost -= 2
    end
    @equip_listen = gen_subscription_to(@wielder, :Attacked, free_money)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_HimitsuShiguresLegacy)