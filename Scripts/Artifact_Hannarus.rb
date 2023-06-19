class Artifact_Hannarus < Artifact

  def self.get_base_stats
    return {
      :name       => "Hannaru's Spear and Aegis",
      :description => "Uses two item slots. Grants huge amounts of power and ward.",
      :cost       => 1,
      :type       => :rare,
      :keys       => ["Spear", "Shield"],
      :impacts    => [
        [Impact, [:POWER, 100]],
        [Impact, [:WARD, 50]]
      ],
      :components => [],
      :back   => [:POWER, :WARD]
    }
  end
  
  def prepare_sprite(placing=nil)
    super
    @sprite2 = new_artifact_sprite
    @sprite2.visible = false
    @sprite2.artifact = self    
    @sprite2.bitmap = RPG::Cache.icon("Artifacts/"+@name+".png")
    @sprite2.z = 7050
    @sprite2.opacity = 150
    @sprite2.off_x = 22
    @sprite2.equip_only = true
    @back_drop2 = new_artifact_sprite
    if $backdrop_bitmaps[:base][@backs.first][@backs.last]
      @back_drop2.b1 = @backs.first
      @back_drop2.b2 = @backs.last
    else
      @back_drop2.b2 = @backs.first
      @back_drop2.b1 = @backs.last
    end
    @back_drop2.cb_bitmap
    @back_drop2.z = 7049
    @back_drop2.opacity = 200
    @back_drop2.add_stick_to(@sprite2)
    @back_drop2.artifact = self
    @back_drop2.equip_only = true
    @back_drop2.visible = false
    @sprite2.subsprites.push(@back_drop2)
    time = 1
  end
  
  def use_slots
    return 2
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
      "Uses two item slots. Grants huge",
      "amounts of power and ward."
    ]
  end
  
end

register_artifact(Artifact_Hannarus)