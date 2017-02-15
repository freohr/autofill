--[[HOW TO]]--[[

Fill and Item sets can be pre-defined for global/force/player usage. Sets are
automaticly updated and verified during on_init or on_configuration_changed. To
read any changes to these files without changing mod version numbers you will
have to run:
/c remote.call("af", "verify_saved_sets")

These are available globaly for everyone. If there is not a set by the same name
in the player or force table then sets from global are used.
global-fill-sets.lua
global-item-sets.lua

These are available for all forces. If there is not a set by the same name
in the player table then sets from force are used.
force-fill-sets.lua
force-item-sets.lua

These will be available to all players.
player-fill-sets.lua
player-item-sets.lua

Priority:
 "max" = use the item with the highest value in your main inventory that is in the category table for the set.
 "min" = use the item with the lowest value in your main inventory that is in the category table for the set.
 "qty" = use the item you have the most of in your main inventory that is in the category table for the set.
 note: Priority #'s for ammo need to be assigned manually

--]]

return {
  ["car"]                  = {group = nil, slots = {{type="fuel", category="fuel-high", priority="max"}, {type="ammo", category = "bullet", priority = "qty"}}},
  ["tank"]                 = {group = nil, slots = {{type="fuel", category="fuel-high", priority="min"}, {type="fuel", category="fuel-high", priority="min"},
                             {type="ammo", category = "bullet", priority = "qty"}, {type="ammo", category = "cannon-shell", priority = "qty"}}},
  ["diesel-locomotive"]    = {group = "locomotives", slots = {{type="fuel", category="fuel-high", priority="max"}}},
  ["boiler"]               = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["burner-inserter"]      = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["burner-mining-drill"]  = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["stone-furnace"]        = {group = "furnaces", slots = {{type="fuel", category="fuel-all", priority="max", limit=5},{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["steel-furnace"]        = {group = "furnaces", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["gun-turret"]           = {group = "turrets", slots = {{category = "bullet", priority = "qty", limit=10}}},
}
