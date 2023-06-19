# GameMaster holds Players and the Pool, and manages Rounds
# 
# Players hold GameBoards, Units, Storefronts, Auras, and Artifacts
#   GameBoard manages Hexes
# Pool manages all the Storefronts
# Rounds manage timings and BoardBridges
#   BoardBriges manage GameBoards, combining them during matches
#
# Units hold Artifacts, Buffs, and Impacts
# Hexes hold AoEs
# AoEs, Auras, Artifacts, and Buffs manage Impacts
# Each of these gives their Impact when a Unit becomes affected by them
# 
# Most of these can create Listeners on each other,
# a small package of code that runs when the host emits a specific symbol
# Units (and other objects) emit symbols for major events like :GainedLife