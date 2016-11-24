
--
-- function autofill.get_slots(entity)
--   local slots = {
--     fuel=0,
--     ammo=0,
--     ammo_categories = {}
--   }
--     if entity.get_fuel_inventory() --[[and entity.get_inventory(defines.inventory.fuel)]] then
--       local inv = entity.get_fuel_inventory()
--       if inv.can_insert(global.defaults.fuel_list[1]) then
--         slots.fuel = #inv
--       end
--     end
--     if entity.type == "car" and entity.get_inventory(defines.inventory.car_ammo) then
--       --workaround until fuel inventory is fixed
--       if entity.get_inventory(defines.inventory.fuel) then
--         slots.fuel = #entity.get_inventory(defines.inventory.fuel)
--       end
--
--       local inv = entity.get_inventory(defines.inventory.car_ammo)
--       slots.ammo = #inv
--       for i=1, #inv do
--         for name, ammo in pairs(global.defaults.ammo_list) do
--           if inv.can_set_filter(i, ammo[1]) then
--             slots.ammo_categories[i] = name
--           end
--         end
--       end
--     end
--     if entity.type == "ammo-turret" and entity.get_inventory(defines.inventory.chest) then
--       local inv = entity.get_inventory(defines.inventory.chest)
--       slots.ammo = #inv
--       for i=1, #inv do
--         for name, ammo in pairs(global.defaults.ammo_list) do
--           if inv.can_insert(ammo[1]) then
--             slots.ammo_categories[i] = name
--           end
--         end
--       end
--     end
--
--   if slots.fuel > 0 or slots.ammo > 0 then
--     return slots
--   else
--     return nil
--   end
-- end
--
--
-- function autofill.on_built_entity(event)
--   if not global.defaults.fillable_entities[event.created_entity.name] then
--     local slots = autofill.get_slots(event.created_entity)
--     if slots then global.defaults.fillable_entities[event.created_entity.name] = slots  end
--   end
-- end
-- script.on_event(defines.events.on_built_entity,function (event) autofill.on_built_entity(event) end)
--
--

local function sp_debug_mod_reset()
  if MOD.reset then
    on_init(true)
    MOD.reset=false
    doDebug(MOD.name .. " was force reset", true)
    MOD.Event.remove(defines.events.on_tick, sp_debug_mod_reset)
  end
end
MOD.Event.register(defines.events.on_tick, sp_debug_mod_reset)
--Debugging function, re-inits mod on first tick if MOD.reset

local function new_player_init(player, reset) --add or update player and players force index in global
  if reset or global.player_data == nil then global.player_data = {} end
  if reset or global.force_data == nil then global.force_data = {} end

  if reset == true or (not global.player_data[player.index] or global.player_data[player.index].name ~= player.name) then
    global.player_data[player.index] = {
      opened = nil, --TODO move to events.init?
      name = player.name, --use for flavor, not all players might have a name...
      index = player.index
    }
    step_through_scripts("new_player_init", player, reset)
    doDebug("new_player_init: Created player: " .. player.index ..":".. player.name)
  end

  if not global.force_data[player.force.name] then
    global.force_data[player.force.name] ={}
    doDebug("new_player_init: Created force: " .. player.force.name)
  end
end

local function all_players_init(reset) --add or update ALL players and player forces
  for _, player in pairs(game.players) do
    doDebug("playerInit: Looking for new players")
    new_player_init(player, reset)

  end
end

local function on_player_created(event)

  local player = game.players[event.player_index]
  doDebug("on_player_created: ".. player.index ..":".. player.name)
  new_player_init(player)
  step_through_scripts("on_player_created", event, false)
end
script.on_event(defines.events.on_player_created, function(event) on_player_created(event) end)
--Called, when a new player is created for the first time.

local function on_player_joined(event)

  local player = game.players[event.player_index]
  doDebug("on_player_joined: ".. player.index ..":".. player.name)
  new_player_init(player)
  step_through_scripts("on_player_created", event, false)
end
script.on_event(defines.events.on_player_joined_game, function(event) on_player_joined(event) end)
--Called, when a new player joins the map for the first time?.

local function on_player_respawned(event)

  local player = game.players[event.player_index]
  doDebug("on_player_respawned: " .. player.index ..":" .. player.name)
  step_through_scripts("on_player_respawned", event, false)
end
script.on_event(defines.events.on_player_respawned, function(event) on_player_respawned(event) end)
--Called MP only, when a player re-spawns after dying

local function on_player_left_game(event)

  local player = game.players[event.player_index]
  doDebug("on_player_left: " .. player.index ..":".. player.name)
  step_through_scripts("on_player_left", event, false)
end
script.on_event(defines.events.on_player_left_game, function(event) on_player_left_game(event) end)
--Called MP, when a player leaves the map?.

local function on_pre_player_died(event)

  local player = game.players[event.player_index]
  doDebug("on_pre_player_died:" .. player.index ..":".. player.name)
  step_through_scripts("on_pre_player_died", event, false)

end
script.on_event(defines.events.on_pre_player_died, function(event) on_pre_player_died(event) end)
--Called ALWAYS, before player dies, fires before on_entity_died, player is still valid at this point.
