class Artifact_ChamberOfReflections < Artifact

  def self.get_base_stats
    return {
      :name       => "Chamber of Reflections",
      :description => "Grants ward and life to wielder and nearby allies " +
        "that share a synergy with it.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Machine"],
      :impacts    => [],
      :components => ["Mageweave Cloak", "Spirit Pendant"],
      :back   => [:WARD, :MAX_LIFE]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Grants ward and life to wielder",
      "and nearby allies that share a",
      "synergy with it."
    ]
  end
  
  def equip_to(target)
    super
    reflect_imps = Proc.new do |aoe, unit|
      [Impact.new(:WARD, 10), Impact.new(:MAX_LIFE, 10)]
    end
    hsh = {
      :source     => @wielder,
      :epicenter  => @wielder,
      :range      => 1,
      :follow     => true,
      :reliant    => @wielder,
      :impacter   => reflect_imps
    }
    @aoe = AoE_Syn_Boon.new(hsh)
  end
  
  def unequip_from(dont_trigger = false)
    @aoe.clear_aoe
    super
  end
  
end

register_artifact(Artifact_ChamberOfReflections)