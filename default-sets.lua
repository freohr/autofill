--   ["entity.name"] = {
--     group = "", --the "group" this entity shares with other entities, optional
--     slots = { -- table of slot tables to be filled
--       {
--         type = "fuel", --type of slot, "fuel" or "ammo", mandatory
--         category = "fuel-all", --fuel category to use, string or table of items, optional default "fuel-all"
--         priority = "max", -- priority for fuel: "max" for highest Mj in inv, "min" for lowest Mj in inv, "qty" for most in inv - default:max
--         limit = "10", -- insert limit amount of items max
--       },
--       {type = "ammo", category = "bullets", priority="qty", limit="10"} --set is ammo-category and mandatory
--       --priority for ammo: "max", "min", "qty".  priorities must be manaually assigned
--     }
--   }
--
return {
  ["stone-furnace"] = {group = "furnace", slots = {{type = "fuel", category = "fuel-all", priority = "max", limit = "10"}}}
}
