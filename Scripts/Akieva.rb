# Akieva
# 2/4/6: Gain 1/2/3 Eureka! counters per battle.
#  Collect a sufficient number to get a rare masterpiece artifact.
class Synergy_Akieva < Synergy
  attr_accessor :research_counters
  
  def initialize(owner)
    super
    @research_counters = 0
  end
  
  def key
    return :AKIEVA
  end
  
  def breakpoints
    return [2, 4, 6]
  end
  
  def sprite
    return "Akieva"
  end
  
  def info_text(lv=level)
    return {
      :name => "Akieva",
      :breaks => breakpoints,
      :level => lv,
      :header => "Research counters: " + @research_counters.to_s +
        "~Collect 8 research counters to get~" +
        "a rare Masterpiece artifact.",
      :blocks => [
        "Earn 1 counter per combat.",
        "Earn 2 counters per combat.",
        "Earn 3 counters per combat."
      ],
      :bm => "6",
      :members => @member_names
    }
  end
  
  
  def deployer
    return true
  end
  
  def init_match_listeners
    @research_counters += [0, 1, 2, 3][level]
    if @owner.has_aura?(UnifiedTheory)
      for m in @members
        next unless m.artifacts.length == 3
        counter = 0
        for a in m.artifacts
          counter += 1 if a.is_completed
        end
        next unless counter == 3
        @research_counters += 1
        break
      end
    end
    if @research_counters >= 8
      @research_counters -= 8
      @owner.give_artifact(masterpieces.sample.new)
    end
  end
  
  def masterpieces
    [
      Artifact_CultivatingSpheres,
      Artifact_MirrorOfPossibilities,
      Artifact_ThriceFoldedLotus
    ]
  end
  
end
register_synergy(Synergy_Akieva, :AKIEVA)