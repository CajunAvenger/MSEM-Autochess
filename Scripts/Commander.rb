# Commander
# @2/4/6/8
# Gain one/two/three/four soldier token units.
# Commanders get bonus power for each soldier currently alive.
class Commander_Soldier < Unit
  def self.get_base_stats
    return {
      :name       => "Soldier",
      :cost       => 0,
      :synergy    => [],
      :range      => [1, 1, 1],
      :power      => [10, 20, 40],
      :multi      => [10, 20, 40],
      :haste      => [1, 20, 40],
      :mana_amp   => [10, 20, 40],
      :archive    => [10, 20, 40],
      :toughness  => [10, 20, 40],
      :ward       => [10, 20, 40],
      :life       => [300, 20, 40],
      :ability_cost => -1
    }
  end
end

class Synergy_Commander < Synergy
  attr_accessor :soldiers
  attr_accessor :soldier_count
  
  def initialize(owner)
    @soldiers = []
    @soldier_count = 0
    super
  end
  
  def key
    return :COMMANDER
  end
  
  def breakpoints
    return [2, 4, 6, 8]
  end
  
  def sprite
    return "Commander"
  end
  
  def info_text(lv=level)
    return {
      :name => "Commander",
      :breaks => breakpoints,
      :level => lv,
      :header => "Commanders gain power for each~" +
        "surviving Soldier.",
      :blocks => [
        "Granted 1 Soldier",
        "Granted 2 Soldiers",
        "Granted 3 Soldiers",
        "Granted 4 Soldiers"
      ],
      :members => @member_names
    }
  end
  
  def deployer
    return true
  end
  
  def add_member(member, leech=false)
    return false unless super
    imp = Impact_Commander.new(:POWER, 30, self)
    @impacting[member.id] = Buff_Eternal.new(self, member, imp)
    check_levels
    return true
  end
  
  def remove_member(ex_member)
    return false unless super
    @impacting[ex_member.id].clear_buff
    check_levels
    return true
  end
  
  def check_levels
    if level > @soldiers.length
      s = Commander_Soldier.new
      @owner.give_unit(s, self)
      @soldiers.push(s)
      check_levels
    elsif level < @soldiers.length
      s = @soldiers[0]
      @owner.remove_unit(s)
      @soldiers.delete(s)
      check_levels
    end
  end
  
end
register_synergy(Synergy_Commander, :COMMANDER)