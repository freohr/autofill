--Priority:
--  "max" = use the item with the highest value in your main inventory that is in the category table for the set.
--  "min" = use the item with the lowest value in your main inventory that is in the category table for the set.
--  "qty" = use the item you have the most of in your main inventory that is in the category table for the set.
--  note: Priority #'s for ammo need to be assigned manually

local sets = {
  --Vanilla

  -- ["car"]                  = {group = nil, slots = {{type="fuel", category="fuel-high", priority="max"}, {type="ammo", category = "bullet", priority = "qty"}}},
  -- ["tank"]                 = {group = nil, slots = {{type="fuel", category="fuel-high", priority="min"}, {type="fuel", category="fuel-high", priority="min"},
  --                            {type="ammo", category = "bullet", priority = "qty"}, {type="ammo", category = "cannon-shell", priority = "qty"}}},
  -- ["diesel-locomotive"]    = {group = "locomotives", slots = {{type="fuel", category="fuel-high", priority="max"}}},
  -- ["boiler"]               = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  -- ["burner-inserter"]      = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  -- ["burner-mining-drill"]  = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["stone-furnace"]        = {group = "furnaces", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  -- ["steel-furnace"]        = {group = "furnaces", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  -- ["gun-turret"]           = {group = "turrets", slots = {{category = "bullet", priority = "qty", limit=10}}},
}


return sets
