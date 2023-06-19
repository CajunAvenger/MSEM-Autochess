class Artifact_HubOfInnovation < Artifact

  def self.get_base_stats
    return {
      :name       => "Hub of Innovation",
      :description => "Grants mana amp and archive to self and nearby allies.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Machine"],
      :impacts    => [],
      :components => ["Iron Signet", "Warded Tome"],
      :back   => [:MANA_AMP, :ARCHIVE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
     "Grants mana amp and archive to",
     "self and nearby allies."
    ]
  end
  
  def equip_to(target)
    super
    hub_imps = Proc.new do |aoe, unit|
      [Impact.new(:MANA_AMP, 10),  Impact.new(:ARCHIVE, 10)]
    end
    hsh = {
      :source     => self,
      :epicenter  => @wielder,
      :range      => 1,
      :follow     => true,
      :reliant    => @wielder,
      :impacter   => hub_imps
    }
    @aoe = AoE_Boon_Eternal.new(hsh)
  end
  
  def unequip_from(dont_trigger = false)
    @aoe.clear_aoe
    super
  end
  
end

register_artifact(Artifact_HubOfInnovation)