class Artifact_SkeletonShield < Artifact

  def self.get_base_stats
    return {
      :name       => "Skeleton Shield",
      :description => "Grants haste and toughness. Also increases action " +
        "delay of nearby enemies.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Shield"],
      :impacts    => [
        [Impact, [:HASTE_MULTI, 0.1]],
        [Impact, [:TOUGHNESS, 10]]
      ],
      :components => ["Cinderblade", "Burnished Plate"],
      :back   => [:HASTE, :TOUGHNESS]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
     "Grants haste and toughness. Also",
     "increases action delay of nearby",
     "enemies."
    ]
  end
  
  def equip_to(target)
    super
    skele_imps = Proc.new do |aoe, unit|
      [Impact.new(:HASTE_MULTI, -0.15)]
    end
    hsh = {
      :source     => self,
      :epicenter  => @wielder,
      :range      => 1,
      :follow     => true,
      :reliant    => @wielder,
      :impacter   => skele_imps
    }
    @aoe = AoE_Curse_Eternal.new(hsh)
  end
  
  def unequip_from(dont_trigger = false)
    @aoe.clear_aoe
    super
  end
  
end

register_artifact(Artifact_SkeletonShield)