class IterativeDesign < Aura
  
  def self.get_base_stats
    return {
      :name => "Iterative Design",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "When combat starts, all",
      "your unattached components",
      "are randomized."
    ]
  end
  
  def self.sprite
    return "Smith"
  end

  def extra_init
    
    iterate = Proc.new do |listen|
      sprs = $artifact_tray.sprites
      sprs.delete(nil)
      rands = []
      for s in sprs
        next unless s.artifact.component
        rs = rand(100)
        if rs == 0
          it = $rare_components.sample.new
          it.empowered = s.artifact.empowered
          rands.push(it)
        else
          r2 = rand($artifacts[:component].length-$rare_components.length)
          it = $artifacts[:component][r2].new
          it.empowered = s.artifact.empowered
          rands.push(it)
        end
        $artifact_tray.take(s).dispose
      end
      for r in rands
        listen.host.give_artifact(r)
      end
    end
    gen_subscription_to(@owner, :Deployed, iterate)

  end

end

register_aura(IterativeDesign)