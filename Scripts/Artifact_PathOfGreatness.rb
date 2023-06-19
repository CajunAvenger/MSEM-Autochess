class Artifact_PathOfGreatness < Artifact

  def self.get_base_stats
    return {
      :name       => "Path of Greatness",
      :description => "Grants haste and ward. Summon cats on kill.",
      :cost       => 1,
      :type       => :completed,
      :keys       => ["Trinket"],
      :impacts    => [
        [Impact, [:HASTE_MULTI, 0.1]],
        [Impact, [:WARD, 10]]
      ],
      :components => ["Cinderblade", "Mageweave Cloak"],
      :back   => [:HASTE, :WARD]
    }
  end
  
  def self.get_description
    return [
     #"Grants power and multistrike chan",
     "Grants haste and ward. Summon",
     "a cat after killing an enemy."
    ]
  end
  
  def equip_to(target)
    super
    cat = Proc.new do |listen, dead_man|
      listen.subscriber.owner.give_unit(CatOfGreatness.new(@wielder.owner, @wielder.level), @wielder)
    end
    @equip_listen = gen_subscription_to(@wielder, :Killed, cat)
  end
  
  def unequip_from(dont_trigger = false)
    @equip_listen.clear_listener
    super
  end
  
end

register_artifact(Artifact_PathOfGreatness)

class CatOfGreatness < Token
  def self.get_base_stats
    return {
      :name       => "Cat of Greatness",
      :cost       => 1,
      :synergy    => [],
      :range      => [1, 1, 2],
      :power      => [20, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [0.8, 20, 40],
      :mana_amp   => [10, 20, 40],
      :archive    => [-100, 20, 40],
      :toughness  => [0, 20, 40],
      :ward       => [0, 20, 40],
      :life       => [250, 20, 40]
    }
  end
end