# A damage event
class Damage
  attr_reader :amount           # base amount being done, edit via methods
  attr_reader :source           # source of damage
  attr_reader :targets          # array of targets, edit via methods
  attr_accessor :keys           # array of keys
  attr_accessor :true_damage    # true damage
  attr_accessor :lifesteal      # % bonus lifesteal
  attr_accessor :temp_lifesteal # % bonus lifesteal from outside effects
  attr_accessor :temp_true_damage # true damage from outside effects
  attr_accessor :execute        # life/percentage to execute at
  attr_accessor :procs          # Proc to run after damage
  BASE_KEYS = []
  
  def initialize(source, targets, amount, true_damage = 0, lifesteal=0, keys = nil)
    @amount = amount
    @source = source
    @targets = targets
    @targets = [@targets] unless @targets.is_a?(Array)
    @amounts = []
    for s in @targets
      @amounts.push(0+amount)
    end
    @lifesteal = lifesteal
    @true_damage = true_damage
    @keys = BASE_KEYS || [] 
    @keys += keys unless keys == nil
    @temp_lifesteal = 0
    @temp_true_damage = 0
    @execute = 0
    @procs = []
  end
  
  def damage_to(unit)
    ind = @targets.index(unit)
    return 0 unless ind
    return @amounts[ind]
  end
  
  def reduce_to(unit, amount)
    ind = @targets.index(unit)
    return unless ind
    @amounts[ind] -= amount
  end
  
  def increase_to(unit, amount)
    ind = @targets.index(unit)
    return unless ind
    @amounts[ind] += amount
  end
  
  def set_to(unit, amount)
    ind = @targets.index(unit)
    return unless ind
    @amounts[ind] = amount
  end
  
  def add_target(unit)
    @targets.push(unit)
    @amounts.push(0+@amount)
  end
  
  def clear_targets
    @targets = []
    @amounts = []
  end
  
  def add_procs(array)
    @procs += array
  end
  
  def add_proc(p)
    @procs.push(p)
  end
  
  def clear_unit(unit)
    ind = @targets.index(unit)
    @targets.delete_at(ind)
    @amounts.delete_at(ind)
  end
  
  # apply damage and discard it
  def resolve
    return if @targets === nil
    # modify damage
    #console.log("caching")
    bls = @source.get_value(:LIFESTEAL)
    btd = 0
    if self.is_a?(Damage_Attack)
      bls += @source.get_value(:LIFESTEAL_ATTACK)
      btd += @source.get_value(:TRUE_DAMAGE_ATTACK)
    elsif self.is_a?(Damage_Ability)
      bls += @source.get_value(:LIFESTEAL_SPELL)
      btd += @source.get_value(:TRUE_DAMAGE_SPELL)
    end
    lsa = []
    tda = []
    for target in @targets
      next unless target
      amount = @amounts[@targets.index(target)]
      #console.log("starting damage " + target.id.to_s + " for " + amount.to_s)
      @source.emit(:DamageOutgoing, self, target)
      target.damage_taken += amount
      target.incoming_damage_modifier(self)
      lsa.push(0+@temp_lifesteal)
      tda.push(0+@temp_true_damage)
      @temp_lifesteal = 0
      @temp_true_damage = 0
    end

    for target in @targets
      next unless target
      amount = @amounts[@targets.index(target)]
      #console.log("pre-modified damage " + target.id.to_s + " for " + amount.to_s)
      ls = bls + @lifesteal + lsa[@targets.index(target)]
      td = btd + @true_damage + tda[@targets.index(target)]
      #console.log("checking toughness")
      if self.is_a?(Damage_Attack) || @keys.include?(:PHYSICAL)
        tough = target.get_value(:TOUGHNESS)
        if tough > 0
          amount = amount.to_f*(100/(100+tough.to_f)).round()
        elsif tough < 0
          amount = amount*(2-(100/(100-tough.to_f))).round()
        end
      elsif self.is_a?(Damage_Ability)
        mr = target.get_value(:MAGIC_RES)
        if mr > 0
          amount = amount.to_f*(100/(100+mr.to_f)).round()
        elsif mr < 0
          amount = amount*(2-(100/(100-mr.to_f))).round()
        end
      end
      amount += td
      @amounts[@targets.index(target)] = amount
      next if amount < 0
      # deal damage
      #console.log("checking shield")
      if target.impacts.include?(:SHIELD)
        for imp in target.impacts[:SHIELD]
          #console.log("s")
          amount = imp.check_shield(amount, self)
        end
      end
      target.current_damage += amount
      #console.log("checking execute")
      if @execute
        cl = target.get_life
        ml = target.get_value(:MAX_LIFE)
        if @execute >= cl
          target.current_damage = ml
          @source.emit(:Executed, target)
        elsif @execute <= 1 && @execute >= cl/ml
          target.current_damage = ml
          @source.emit(:Executed, target)
        end
      end
      #console.log("checking procs")
      if @procs.length > 0
        for p in @procs
          p.call(target, amount, self)
        end
      end
      #console.log("check mana heal")
      unless target.mana_cooldown > 0
        mana_gain = (0.07*amount + 0.01*@amount).cap(42)
        target.apply_mana_heal(Impact.new(:MANAGAIN, mana_gain))
      end
      #log damage dealt
      @source.damage_dealt += amount
      target.update_life
      #check lifesteal
      #console.log("checking lifesteal")
      li = amount*ls
      if li > 0
        @source.apply_heal(Impact.new(:HEALING, li))
      elsif li < 0
        @source.apply_anti_heal(Imact.new(:BLEED, -li), self)
      end
    end
    #trigger
    #console.log("emitting")
    for target in @targets
      next unless target
      amount = @amounts[@targets.index(target)]
      @source.emit(:DealtDamage, target, self) if amount > 0
      target.emit(:Damaged, self) if amount > 0
      target.death_check(self)
    end
    #null out this event
    @amounts = nil
    @source = nil
    @targets = nil
    @keys = nil
  end

end