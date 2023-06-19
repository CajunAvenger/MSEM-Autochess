class CurioPavilion < Aura
  
  def self.get_base_stats
    return {
      :name => "Curio Pavilion",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Gain two random",
      "components.",
      "You can sell artifacts."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    t = 2
    rt = rand(100)
    if rt == 0
      @owner.give_artifact($rare_components.sample.new)
      t -= 1
    end
    for i in 1..t
      r2 = rand($artifacts[:component].length-$rare_components.length)
      @owner.give_artifact($artifacts[:component][r2].new)
    end
    @owner.sell_artifacts = true
    
  end
  

end

register_aura(CurioPavilion)