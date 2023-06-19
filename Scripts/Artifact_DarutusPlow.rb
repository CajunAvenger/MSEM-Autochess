class Artifact_DarutusPlow < Artifact

  def self.get_base_stats
    return {
      :name       => "Darutu's Plow",
      :description => "Grants power and toughness. Bearer and adjacent allies " +
        "get bonus power based on their toughness.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Machine"],
      :impacts    => [
        [Impact, [:POWER, 10]],
        [Impact, [:TOUGHNESS, 10]]
      ],
      :components => ["Seishin's Edge", "Burnished Plate"],
      :back   => [:POWER, :TOUGHNESS]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants power and toughness, plus",
      "bonus power to self and nearby",
      "allies based on their toughness."
    ]
  end
  
  def equip_to(target)
    super
    darutu_imps = Proc.new do |aoe, unit|
      [Impact_SelfPercent.new(:POWER, 0.5, :TOUGHNESS)]
    end
    hsh = {
      :source     => self,
      :epicenter  => @wielder,
      :range      => 1,
      :follow     => true,
      :reliant    => @wielder,
      :impacter   => darutu_imps
    }
    @aoe = AoE_Boon_Eternal.new(hsh)
  end
  
  def unequip_from(dont_trigger = false)
    @aoe.clear_aoe
    super
  end
  
end

register_artifact(Artifact_DarutusPlow)