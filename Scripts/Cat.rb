# Cats
# @2
# Cats have no action delay when attacking after moving,
#  and ranged cats keep moving to maintain ideal range.
# @4
# Cats have reduced action delay when moving after attacking.
class Synergy_Cat < Synergy
  
  def key
    return :CAT
  end
  
  def breakpoints
    return [2, 4]
  end
  
  def sprite
    return "Cat"
  end
  
  def info_text(lv=level)
    return {
      :name => "Cat",
      :breaks => breakpoints,
      :level => lv,
      :blocks => [
        "Cats have no action delay after~" +
        "moving. Ranged cats keep moving~" + 
        "to maintain max attack range.",
        "Cats have reduced action delay~" +
        "when moving after attacking."
      ],
      :bm => 5,
      :members => @member_names
    }
  end
  
  def post_combat(unit, attack_keys)
    lv = level
    if attack_keys[:cat_level]
      if attack_keys[:cat_level] < lv && attack_keys.include?(:cat_ticker)
        unit.ticker -= attack_keys[:cat_ticker]
      end
      return
    end
    range = unit.get_value(:RANGE)
    # if our aggro is still around and we're ranged
    if range > 1 && attack_keys[:aggro].current_hex
      moved = false
      info = attack_keys[:aggro].current_hex.get_range_distance_to(unit.current_hex, 1)
      outer_ring = info[1][info[0]+1][:hexes] & unit.current_hex.get_neighbors
      # and they're within range
      if range > info[0]
        scores = {}
        revs = {
          :top_right => [:right, :top_left],
          :top_left => [:top_right, :left],
          :bottom_right => [:right, :bottom_left],
          :bottom_left => [:left, :bottom_right],
          :right => [:top_right, :bottom_right],
          :left => [:top_left, :bottom_left],
          :top => [:top_left, :top_right],
          :bottom => [:bottom_left, :bottom_right]
        }
        dir = unit.current_hex.get_direction_to(attack_keys[:aggro].current_hex)
        scores = []
        # figure best hex to move to
        # TODO don't corner yourself?
        for h in outer_ring
          score = {:hex => h, :score => 0}
          next if h.battler
          dir2 = h.get_direction_to(unit.current_hex)
          score[:score] -= 1 if dir2 == dir
          score[:score] -= 0.5 if revs[dir].include?(dir2)
          scores.push(score)
        end
        sorted = scores.sort_by {|v| v[:score]}
        for hsh in sorted
          h = hsh[:hex]
          moved = h.set_battler(unit)
          if moved
            unit.ticker -= 0.3*unit.tps unless lv > 1
            attack_keys[:cat_ticker] = -0.3*unit.tps unless lv > 1
            break
          end
        end
      end
    elsif !attack_keys[:aggro].current_hex && lv > 1
      # we killed the target
      # if we're out of targets, refund us 10%
      unit.aggro = unit.get_aggro(range)[0]
      unless unit.aggro
        unit.ticker += 0.1*unit.tps/unit.get_value(:HASTE)
      end
    end
    attack_keys[:cat_level] = lv
  end
  
end
register_synergy(Synergy_Cat, :CAT)