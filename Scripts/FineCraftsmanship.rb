class FineCraftsmanship < Aura
  
  def self.get_base_stats
    return {
      :name => "Fine Craftsmanship",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain four random",
      "components."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    t = 4
    rt = rand(100)
    if rt == 0
      @owner.give_artifact($rare_components.sample.new)
      t -= 1
    end
    for i in 1..t
      r2 = rand($artifacts[:component].length-$rare_components.length)
      @owner.give_artifact($artifacts[:component][r2].new)
    end
  end

end

register_aura(FineCraftsmanship)