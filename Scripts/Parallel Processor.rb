$game_master = GameMaster.new(1, $default_settings)
$player = $game_master.players[0]
$tick_loops = 3
$frames_per_second = 40.0
$quarter_second = $frames_per_second / 4
$ticks_per_second = $frames_per_second * $tick_loops
$match = nil
$processor_status = :initialize
$viewport = nil
$sprite = nil
$timer = nil
$slow_match = nil
def fps
  return $frames_per_second
end
def tps
  return $tick_loops * fps
end
# do this so online can share a seed
def beep
  if $sprite
    $sprite.angle += 1
  else
    $sprite = $scene.spriteset.add_anim_to_port(Sprite_Chess)
    $sprite.bitmap = Bitmap.new("Graphics/Icons/Ability/flynn_fire_bl.png")
    $sprite.x = 384
    $sprite.y = 400
    $sprite.z = 6000
    $sprite.ox = 121
    $sprite.oy = 36
    $sprite.angle = 0
  end
end

def parallel_processor
  #console.log($processor_status)
  case $processor_status
  when :initialize
    # set up the game
    $processor_status = :waiting_for_game_start
    $walker_pool = Pool.new($game_master.players)
    $game_master.next_round
    $player.storefront.round_up
    r = rand($planeswalkers[1].length)
    $player.give_unit($planeswalkers[1][r].new)
    $player.give_unit(Rain.new)
    $player.give_unit(Ameret.new)
    $my_auras = AuraTray.new($player)
    $your_auras = AuraTray.new(nil)
    $processor_status = :prepping_match
    $player.give_aura(KaorsTithe.new($player))
    $player.give_artifact(Artifact_SeishinsEdge.new)
    $player.give_artifact(Artifact_SeishinsEdge.new)
  when :prepping_match
    # cycle until Match is ready
    return unless $player.match
    $match = $player.match
    # get :draft or :planning_phase_begin from the round
    $match.round.starting_status
  when :draft_phase
    # drafting phase
  when :planning_phase_begin
    # the things that happen at the beginning of the planning phase
    # add interest to cached passive income
    $player.round_gold += $player.grab_interest
    $player.give_gold($player.round_gold, :round)
    $player.round_gold = 0
    # reroll the shop
    $player.star_up_check
    $match.status = :begin_planning
    $processor_status = :planning_phase
  when :planning_phase
    # cycle during the planning phase for 30 seconds
    $match.main
  when :combat_phase
    # autobattler phase. mouse is disabled for the board
    $match.main
  when :begin_round
    $player.gain_xp(2)
    # begin the next round
    $game_master.next_round
    $player.storefront.round_up
    $processor_status = :prepping_match
  when :match_victory
    # it's over!
    console.log("you win")
  when :match_loss
    # it's over!
    console.log("you lose")
  end
end
=begin
  :initialize
  :waiting_for_game_start
  
  :prepping_match         make sure $match is ready
  :planning_phase_begin   in PvE, show the mobs here
  :planning_phase         $match.main switches us to
  :combat_phase           in PvP, show the movs herer
                          $match sends us to either...
  :begin_round            restarts the loop
  :draft                  enter a draft round
  :match_loss             you lost
  :match_victory          you won
=end
