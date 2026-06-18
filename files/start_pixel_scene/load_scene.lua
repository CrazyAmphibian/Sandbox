dofile_once("data/scripts/perks/perk.lua")
local base_x,base_y = 224,-112


perk_spawn( base_x-32, base_y, "EDIT_WANDS_EVERYWHERE", true )
perk_spawn( base_x, base_y, "UNLIMITED_SPELLS", true )
perk_spawn( base_x+32, base_y, "REMOVE_FOG_OF_WAR", true )