# loop_guard
# set active when going into potential loop scenarios to keep track
# clear it out at the end
$loop_guard = {:active => false}

$Streak_Base = [0, 0, 1, 1, 2, 3]
$Plan_Gold = [0, 5, 2, 2, 3, 4, 5]
$Level_xp = [2, 2, 2, 6, 10, 20, 36, 56, 80]
$colorblind = false
$artifact_sprites = []

# Symbol reference storage
$stats = []
$impacts = []
$synergies = {}
$syn_sprites = {}
$planeswalkers = {
  :all => [],
  1 => [],
  2 => [],
  3 => [],
  4 => [],
  5 => [],
  :name_map => {}
}
$auras = []
$artifacts = {
  :component => [],
  :completed => [],
  :rare => [],
  :dummy => [],
  :name_map => {},
  :build_map => {}
}
$component_names = []
$rare_components = []

$ability_aims = {}
$custom_aims = {}
$ability_ally = {}
$ability_areas = {}
$custom_areas = {}
$ability_methods = {}

# core stats, :MAX_LIFE, :POWER, etc
def register_stat(sym)
  $stats.push(sym) unless $stats.include?(sym)
end
# impact keys, :HEALING, :TAUNT
def register_impact(sym)
  $impacts.push(sym) unless $impacts.include?(sym)
end
# synergy keys, :AKIEVA, :WIZARD
def register_synergy(class_con, label_sym)
  $synergies[label_sym] = class_con unless $synergies.include?(label_sym)
end


# the Planeswalker classes
# save them overall and in a cost-specific array
# so can get any planeswalker from $planeswalkers[0]
# or an X cost planeswalker from $planeswalkers[X]
def register_planeswalker(cname)
  $planeswalkers[:all].push(cname) unless $planeswalkers[:all].include?(cname)
  cost = cname.get_base_stats[:cost]
  $planeswalkers[cost].push(cname) unless $planeswalkers[cost].include?(cname)
  name = cname.get_base_stats[:name]
  $planeswalkers[:name_map][name] = cname
  $ability_aims[name] = cname.ability_aim
  $ability_areas[name] = cname.ability_area
  method_name = name.downcase
  method_name = method_name.gsub(/ .+/, "").gsub("'", "")
  $ability_methods[name] = ("ability_script_"+method_name).to_sym
  $ability_ally[name] = cname.ally_type
  customs = [:custom, :custom_ward, :custom_unward]
  if customs.include?($ability_aims[name][0])
    $custom_aims[name] = ("aim_script_"+method_name).to_sym
  end
  if customs.include?($ability_areas[name][0])
    $custom_areas[name] = ("area_script_"+method_name).to_sym
  end
  for s in cname.get_base_stats[:synergy]
    $planeswalkers[s] = [] unless $planeswalkers[s]
    $planeswalkers[s].push(cname)
  end

end

def register_artifact(cname)
  stats = cname.get_base_stats
  $artifacts[stats[:type]].push(cname) unless $artifacts[stats[:type]].include?(cname)
  $artifacts[:name_map][stats[:name]] = cname
  if stats.include?(:components) && stats[:components].length == 2
    c1 = stats[:components][0]
    c2 = stats[:components][1]
    $artifacts[:build_map][c1] = {} unless $artifacts[:build_map].include?(c1)
    $artifacts[:build_map][c2] = {} unless $artifacts[:build_map].include?(c2)
    $artifacts[:build_map][c1][c2] = cname
    $artifacts[:build_map][c2][c1] = cname
  end
  if stats[:type] == :component
    $component_names.push(stats[:name])
    $rare_components.push(cname) if stats[:rare]
  end
end

def register_aura(sym)
  $auras.push(sym) unless $auras.include?(sym)
end

register_stat(:RANGE)
register_stat(:MAX_LIFE)
register_stat(:POWER)
register_stat(:MULTI)
register_stat(:HASTE)
register_stat(:MANA_AMP)
register_stat(:ARCHIVE)
register_stat(:TOUGHNESS)
register_stat(:WARD)

register_impact(:RANGE)
register_impact(:MAX_LIFE)
register_impact(:POWER)
register_impact(:MULTI)
register_impact(:HASTE)
register_impact(:MANA_AMP)
register_impact(:ARCHIVE)
register_impact(:TOUGHNESS)
register_impact(:WARD)
register_impact(:HEALING)
register_impact(:MANAGAIN)
register_impact(:TORMENT)
register_impact(:CLOAK)
register_impact(:LIFESTEAL)
register_impact(:INVULNERABLE)
register_impact(:SHIELD)

register_impact(:POWER_MULTI)
register_impact(:MULTI_MULTI)
register_impact(:HASTE_MULTI)
register_impact(:MANA_AMP_MULTI)
register_impact(:ARCHIVE_MULTI)
register_impact(:TOUGHNESS_MULTI)
register_impact(:WARD_MULTI)
register_impact(:ERUPTION)


# Class Keys
# symbols can be converted to their class with get_class(:SYMBOL)
def get_class(sym)
  return Kernel.const_get(sym)
end

# ID numbers
# so we can distinguish between instances of each class

$next_unit_id = 0
$next_artifact_id = 0
$next_aura_id = 0
$next_player_id = 0
$next_buff_id = 0
$next_aoe_id = 0
$next_listener_id = 0
$next_impact_id = 0
$next_match_id = 0

def get_unit_id
  return $next_unit_id += 1
end

def get_artifact_id
  return $next_artifact_id += 1
end

def get_aura_id
  return $next_aura_id += 1
end

def get_player_id
  return $next_player_id += 1
end

def get_buff_id
  return $next_buff_id += 1
end

def get_aoe_id
  return $next_aoe_id += 1
end

def get_listener_id
  return $next_listener_id += 1
end

def get_impact_id
  return $next_impact_id += 1
end

def get_match_id
  return $next_match_id += 1
end


def reverse_direction(dir)
  all = reverse_directions(dir)
  return all[0] if all
end

def reverse_directions(dir)
  case dir
  when :top_left
    return [:bottom_right, :bottom_left, :right]
  when :top
    return [:bottom, :bottom_left, :right]
  when :top_right
    return [:bottom_left, :left, :bottom_right]
  when :right
    return [:left, :top_left, :bottom_right]
  when :bottom_right
    return [:top_left, :top_right, :left]
  when :bottom
    return [:top, :top_right, :top_left]
  when :bottom_left
    return [:top_right, :right, :top_left]
  when :left
    return [:right, :bottom_right, :top_right]
  end
end

def has_infobox?
  return false
end

# The color backdrops for artifact sprites
$backdrop_bitmaps = {}
def build_bitmaps
  stats = ["POWER", "MULTI", "HASTE", "MANA_AMP", "ARCHIVE", "TOUGHNESS", "WARD", "MAX_LIFE", "UNIQUE"]
  $backdrop_bitmaps = {:base => {}, :colorblind => {}}
  r = Rect.new(0, 0, 22, 22)
  for i in 0..stats.length-1
    prim = stats[i]
    ps = prim.to_sym
    $backdrop_bitmaps[:base][ps] = {}
    $backdrop_bitmaps[:colorblind][ps] = {}
    $backdrop_bitmaps[ps] = {}
    for j in i..stats.length-1
      secondary = stats[j]
      ss = secondary.to_sym
      base = Bitmap.new("Graphics/Icons/Blocks/"+prim+".png")
      base_cb = Bitmap.new("Graphics/Icons/Blocks/colorblind/"+prim+".png")
      if ps == ss
        $backdrop_bitmaps[:base][ps][ss] = base
        $backdrop_bitmaps[:colorblind][ps][ss] = base_cb
      else
        half = Bitmap.new("Graphics/Icons/Blocks/"+secondary+"_half.png")
        half_cb = Bitmap.new("Graphics/Icons/Blocks/colorblind/"+secondary+"_half.png")
        base.blt(0, 0, half, r)
        $backdrop_bitmaps[:base][ps][ss] = base
        base_cb.blt(0, 0, half_cb, r)
        $backdrop_bitmaps[:colorblind][ps][ss] = base_cb
      end
    end
  end
end

def apply_bitmaps
  for a in $artifact_sprites
    a.cb_bitmap
  end
end

build_bitmaps
apply_bitmaps

class Bitmap
  
  def shrink_to(text, w=self.width)
    hold = self.font.size
    loop do
      rect = self.text_size(text)
      if rect.width > w
        self.font.size -= 0.5
      elsif self.font.size < 1
        self.font.size = hold
        return
      else
        return
      end
    end
  end
  
end