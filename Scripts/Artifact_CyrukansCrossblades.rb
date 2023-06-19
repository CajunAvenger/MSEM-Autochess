class Artifact_CyrukansCrossblades < Artifact

  def self.get_base_stats
    return {
      :name       => "Cyrukan's Crossblades",
      :description => "Grants power and life. Hits burn for damage over time.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Sword"],
      :impacts    => [
        [Impact, [:POWER, 10]],
        [Impact, [:MAX_LIFE, 10]]
      ],
      :components => ["Seishin's Edge", "Spirit Pendant"],
      :back   => [:POWER, :MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants power and life. Attacks",
      "also burn for damage over time."
    ]
  end
  
  def equip_to(target)
    super
    burninate = Proc.new do |target, amount|
      DoT.new(@wielder, target, 40, 2, "Cyrukan's Scars")
    end
    
    on_hit = Proc.new do |listen, attack_keys|
      attack_keys[:procs].push(burninate)
    end
    
    @equip_listener = gen_subscription_to(@wielder, :Attacking, on_hit)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listener.clear_listener
    super
  end
  
end

register_artifact(Artifact_CyrukansCrossblades)