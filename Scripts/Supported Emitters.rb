=begin

Supported emit() instances with their parameters
Proc.new do |listener, *params|
params? may be nil

non-match emits will be mirrored by match
unit and artifact emits will be mirrored by owner
Proc.new do |listener, main_emitter, *params|

PLAYER EMITS
  :SynergyLocked
  :SynergyUnocked
  :Deployed
  :AuraChosen, aura
  :XPGained
  :LevelUp
  :LostLife, amount
  :LifeChanged, amount
  :Losing
  :RecoveredLife, amount
  :GainedGold, amount
  :RoundWon, streak
  :RoundLost, streak
  :RoundResolved, streak
  :Sacrificed, unit
  :PlayerGainingImpact, impact
  :PlayerLosingImpact, impact
  :UnitBought, unit
  :UnitSold, unit
  :Looted, contents
  :Summoned, unit

MATCH EMITS
  :RoundStart
  :RoundEnd
  :Frame, combat_frames
  :Quarter, combat_frames
  :Tick, combat_frames

AOE EMITS
  :AoeExpired

ARTIFACT EMITS
  :EquippedTo, unit
  :UnequippedFrom, unit

BUFF EMITS
  :Expired
  
SYNERGY EMITS
  :NewMember, unit
  :LostMember, unit

UNIT EMITS
  :Buffing, buff
  :BeingBuffed, buff
  :Died, unit, old_hex, damage_event?
  :StarredUp
  :Stunned
  :IncomingDamage, damage_event
  :DamageOutgoing, damage_event, target
  :Executed, target
  :DealtDamage, target, damage_event
  :Damaged, damage_event
  :Moved, old_hex, current_hex
  :BoardChange
  :Upgraded, built_artifact
  :EquipmentChange
  :Equipped, artifact
  :Unequipped, artifact
  :GainingImpact, impact
  :LosingImpact, impact
  :GainingLife, impact
  :GainedLife, amount
  :GainingMana, impact
  :GainedMana, amount
  :Dying, damage_event?
  :Died, dead_unit, old_hex, damage_event?
  :Killed, dead_unit, old_hex, damage_event
  :Attacking, attack_keys
  :BeingAttacked, attack_keys
  :Attacked, attack_keys
  :Multistriked, attack_keys, i
  :CatTax, attack_keys
  :DoneAttacking, attack_keys
  :Warded, amount
  :BeingTargeted, targeter, target_info
  :BeingTargetedAlly, targeter, target_info
  :BeingTargetedEnemy, targeter, target_info
  :Casting, target_info, cost, unit_key
  :UsedAbility, target_info, iteration_array

=end