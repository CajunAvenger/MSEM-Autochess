class Artifact_IldrinTheApexBlade < Artifact

  def self.get_base_stats
    return {
      :name       => "Ildrin, the Apex Blade",
      :description => "Grants multistrike chance. Attacks can multistrike " +
        "up to three additional times.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Sword"],
      :impacts    => [
        [Impact, [:MULTI, 20]]
      ],
      :components => ["Flintlock Pistol", "Flintlock Pistol"],
      :back   => [:MULTI]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants multistrike chance.",
      "Attacks can multistrike up to",
      "three additional times."
    ]
  end
  
  def equip_to(target)
    super
    triple = Proc.new do |listen, attack_keys|
      for i in 1..3
        attack_keys[:times] += 1 if rand(100) < attack_keys[:multi]
      end
    end
    @equip_listen = gen_subscription_to(@wielder, :Attacking, triple)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_IldrinTheApexBlade)