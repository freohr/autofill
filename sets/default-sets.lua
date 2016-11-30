--   ["entity-name"] = {
--     group = "", --the "group" this entity shares with other entities, optional
--     slots = { -- table of slot tables to be filled
--       {
--         category = "category-name", --name of the category to use: see default categories below
--         priority (optional) = "max", "min", "qty" -- default is "qty"
--         limit (optional) = "10", --If limits are enabled only insert at most this many items.
--       },
--   }
--
--Default Fuel Categories:
--  "fuel-high" -- Table of fuels that have a fuel value equal to or greater than coal
--  "fuel-all" -- Table of ALL fuels
--Default(vanilla) Ammo Categories: "bullet", "cannon-shell", "flame-thrower", "railgun", "rocket", "shotgun-shell",
--Adding custom categories is done via the GUI?

--Priority:
--  "max" = use the item with the highest value in your main inventory that is in the category table for the set.
--  "min" = use the item with the lowest value in your main inventory that is in the category table for the set.
--  "qty" = use the item you have the most of in your main inventory that is in the category table for the set.
--  note: Priority #'s for ammo need to be assigned manually

local sets = {
  --Vanilla

  ["car"]                  = {group = nil, slots = {{type="fuel", category="fuel-high", priority="max"}, {type="ammo", category = "bullet", priority = "qty"}}},
  ["tank"]                 = {group = nil, slots = {{type="fuel", category="fuel-high", priority="min", slot_count=2},
                             {type="ammo", category = "bullet", priority = "qty"}, {type="ammo", category = "cannon-shell", priority = "qty"}}},
  ["diesel-locomotive"]    = {group = "locomotives", slots = {{type="fuel", category="fuel-high", priority="max"}}},
  ["boiler"]               = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["burner-inserter"]      = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["burner-mining-drill"]  = {group = "burners", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["stone-furnace"]        = {group = "furnaces", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["steel-furnace"]        = {group = "furnaces", slots = {{type="fuel", category="fuel-all", priority="max", limit=5}}},
  ["gun-turret"]           = {group = "turrets", slots = {{category = "bullet", priority = "qty", limit=10}}},
}

--retrieve mod sets and add to table
for name, set_table in pairs(require("sets/default-mod-sets")) do
  sets[name] = set_table
end

return sets
