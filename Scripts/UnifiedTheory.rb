class UnifiedTheory < Aura
  
  def self.get_base_stats
    return {
      :name => "Unified Theory",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "You gain an additional research",
      "counter each combat while you",
      "have an Akiva unit with three",
      "completed items equipped.",
      "Gain a Volta."
    ]
  end
  
  def self.sprite
    return "Buff"
  end
  
  def extra_init
    # Gain a Volta
    give_unit(Volta)
  end

end

register_aura(UnifiedTheory)