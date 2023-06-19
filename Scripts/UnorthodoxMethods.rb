class UnorthodoxMethods < Aura
  
  def self.get_base_stats
    return {
      :name => "Unorthodox Methods",
      :tier  => 1
    }
  end
  
  def self.get_description
    return [
      "Experience costs life instead of gold."
    ]
  end
  
  def self.sprite
    return "Spend"
  end

  def extra_init
    
    @owner.storefront.blood_xp if @owner.storefront

  end

end

register_aura(UnorthodoxMethods)