class Artifact_Awestone < Artifact

  def self.get_base_stats
    return {
      :name       => "Awestone",
      :description => "Enemies the wielder would stun become confused and" +
        "attack their allies instead.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Trinket"],
      :impacts    => [],
      :back   => [:UNIQUE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Enemies the wielder would stun",
      "become confused and attack their",
      "allies instead."
    ]
  end
  
  def equip_to(target)
    super
    switch = Proc.new do |listen, buff|
      for i in buff.impacts
        i.id = :CONFUSED if i.id == :STUN
      end
    end
    @equip_listener = gen_subscription_to(@wielder, :Buffing, switch)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listener.clear_listener
    super
  end
  
end

register_artifact(Artifact_Awestone)