# All players are pulling from the same pool but see their own portion of it
# Pool controls the central system
# while Storefronts control the player's individual pools
# Storefront and walker drops will refer to Pool for new data
# $walker_pool is the instance of this class
class Pool
  
  Odds_Table = [
    [100, 0, 0, 0, 0],
    [100, 0, 0, 0, 0],
    [75, 25, 0, 0, 0],
    [55, 25, 15, 0, 0],
    [45, 33, 20, 2, 0],
    [25, 40, 30, 5, 0],
    [19, 30, 35, 15, 1],
    [16, 20, 35, 25, 4],
    [9, 15, 30, 30, 16],
    [5, 10, 20, 40, 25],
    [1, 2, 12, 50, 35]
  ]
  
  def initialize(players)
    @storefronts = {}
    @warehouse = {1 => [], 2 => [], 3 => [], 4 => [], 5 => []}
    stock_up(29, 22, 18, 12, 10)
    for p in players
      # single player mode
      next unless p.id == 1
      p.storefront = Storefront.new(p, self)
      @storefronts[p.id] = p.storefront
    end
  end
  
  def stock_up(*args)
    for i in 1..args.length do
      val = args[i-1]
      next if val == 0
      walks = $planeswalkers[i]
      for w in walks
        for x in 1..val
          @warehouse[i].push(w)
        end
      end
    end
  end
  
  def class_from(name)
    test = $planeswalkers[:name_map][name]
    return test unless test == nil
    return name
  end
  
  def cost_from(cname)
    return cn.get_base_stats[:cost]
  end
  
  def restock(names)
    names = [names] unless names.is_a?(Array)
    for cn in names
      cost = cn.get_base_stats[:cost]
      @warehouse[cost].push(cn)
    end
  end
  
  def try_remove(names)
    for n in names
      cn = class_from(n)
      cost = cn.get_base_stats[:cost]
      ind = @warehouse[cost].index(cn)
      @warehouse[cost].delete_at(ind)
    end
  end
  
  def roll_unit(level, common_units=[])
    # first roll for tier
    lv_ind = level-1
    lv_ind = Odds_Table.length-1 if level > Odds_Table.length
    odds = Odds_Table[lv_ind]
    r = rand(100)
    cind = -1
    for c in 0..(common_units.length-1)
      rc = rand(100)
      if rc < 33
        cind = c
        break
      end
    end
    b = 0
    for x in 0..odds.length-1
      cost = odds.length-x      # 5, 4, 3
      cost_ind = cost-1         # 4, 3, 2
      group = @warehouse[cost]
      if cind > -1
        group = @warehouse[cost] & $planeswalkers[common_units[cind]]
      end
      if group.length == 0
        # out of stock here, bump
        b += odds[cost_ind]
      elsif r - b >= odds[cost_ind]
        # rolled too high, bump
        b += odds[cost_ind]
      else
        # valid grab
        r2 = rand(group.length)
        unit = group[r2]
        @warehouse[cost].delete_at(@warehouse[cost].index(unit))
        return unit
      end
    end
  end
  
  def reroll(storefront, level, opts=[])
    new_stock = []
    # get five new walkers
    for i in 1..5 do
      new_stock.push(roll_unit(level, storefront.player.common_units))
    end
    restock(storefront.stock)
    return new_stock
  end
  
  def roll_from_opts(opts, cost=1, roll_down=false)
    loop do
      opts2 = opts & @warehouse[cost]
      if opts2.length > 0
        ind1 = rand(opts2.length)
        ind2 = @warehouse[cost].index(opts2[ind1])
        unit = @warehouse[cost][ind2]
        @warehouse[cost].delete_at(ind2)
        return unit
      else
        break unless roll_down
        level -= 1
        break if level == 0
      end
    end
    return nil
  end

end