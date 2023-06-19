# Sisters
# @Flynn
# Sisters' gain power and toughness
# @Karina
# Sisters' spells cast twice.
# @Mei
# Sisters' attacks reduce the rate at which the target's spells charge
class Synergy_Sisters < Synergy
  
  def key
    return :SISTERS
  end
  
  def initialize(owner)
    @buff_cache = {}
    super
  end
  
  def breakpoints
    return [1, 2, 3]
  end
  
  def sprite
    return "Sisters"
  end
  
  def info_text(lv=level)
    return {
      :name => "Sisters",
      :breaks => breakpoints,
      :level => lv,
      :blocks => {
        "Flynn" => "Flynn and her sisters gain~power and toughness.",
        "Karina" => "Karina and her sisters'~spells cast twice.",
        "Mei" => "Mei and her sisters attacks~reduce the target's archive."
      },
      :members => @member_names
    }
  end
  
  def add_member(member, leech=false)
    super
    @buff_cache[member.id] = []
    
    # add Flynn's buff
    imp = Impact_FlynnSisterhood.new(:POWER, 20, self)
    imp2 = Impact_FlynnSisterhood.new(:TOUGHNESS, 20, self)
    efs = [imp, imp2]
    fbuff = Buff_Eternal.new(self, member, efs, "Sisters' Bravery", ["Synergy"])
    @buff_cache[member.id].push(fbuff)

    # add Karina's listener
    inquiring_mind = Proc.new do |listen, cost, iter|
      next if iter.include?(:Sisters)
      next unless listen.subscriber.source.member_names.include?("Karina")
      iter.push(:Sisters)
      sister = listen.host
      karina = nil
      for u in sister.owner.deployed
        if u.name == "Karina"
          karina = u
          break
        end
      end
      if karina
        karina.try_ability(sister.name, 0, iter)
      else
        sister.try_ability(sister.name, 0, iter)
      end
    end
    kbuff = Buff_Eternal.new(self, member, [], "Sisters' Inquiry", ["Synergy", "Ability"])
    kbuff.gen_subscription_to(member, :UsedAbility, inquiring_mind)
    @buff_cache[member.id].push(kbuff)

    # add Mei's listener
    losing_your_mind = Proc.new do |listen, attack_keys, i|
      next unless listen.subscriber.source.member_names.include?("Mei")
      src = listen.host
      trg = attack_keys[:aggro]
      imp = Impact.new(:ARCHIVE, -10)
      Debuff.new(src, trg, [imp], "Pieces of Mind", ["Synergy"])
    end
    mbuff = Buff_Eternal.new(self, member, [], "Sister's Hearthache", ["Synergy", "Attack"])
    mbuff.gen_subscription_to(member, :Attacked, losing_your_mind)
    @buff_cache[member.id].push(mbuff)
      
    end
  
  def remove_member(ex_member)
    return unless @members.include?(ex_member)
    for buff in @buff_cache[ex_member.id]
      buff.clear_buff()
    end
    super
  end
  
  def buff_visible?(buff)
    case buff.name
    when "Sisters' Bravery"
      return @member_names.include?("Flynn")
    when "Sisters' Inquiry"
      return @member_names.include?("Karina")
    when "Sisters' Heartache"
      return @member_names.include?("Mei")
    else
      return true
    end
  end
end
register_synergy(Synergy_Sisters, :SISTERS)