--luacheck: globals autofill
local autofill = {}
autofill.gui = require("gui")

-------------------------------------------------------------------------------
--[[autofill functions]]--

--set table
autofill.default_items = {}
autofill.default_sets = require("default-sets")

local prototype_set_table = { --luacheck: ignore
  ["entity.name"] = {
    group = "", --the "group" this entity shares with other entities, optional
    slots = { -- table of slot tables to be filled
      {
        type = "fuel", --type of slot, "fuel" or "ammo", mandatory
        category = "fuel-all", --fuel category to use, string or table of items, optional default "fuel-all"
        priority = "max", -- priority for fuel: "max" for highest Mj in inv, "min" for lowest Mj in inv, "qty" for most in inv - default:max
        limit = "10", -- insert limit amount of items max
      },
      {type = "ammo", category = "bullets", priority="qty", limit="10"} --set is ammo-category and mandatory
      --priority for ammo: "max", "min", "qty".  priorities must be manaually assigned
    }
  }
}

function autofill.fill_entity(event) --luacheck: ignore event
  local player = game.players[event.player_index]
  local entity = event.created_entity
  local pdata = global.player_data[event.player_index]
  local fdata = global.force_data[player.force.name]

  if global.enabled and pdata.enabled and fdata.enabled and pdata.sets[entity.name] then
    player.print("Filling Entity")
  end --enabled with set


end
Event.register(defines.events.on_built_entity, autofill.fill_entity)

--list is updated during init and configuration_changed
function autofill.get_items()
  local fuel_list, ammo_list = {}, {}
  for _, item in pairs(game.item_prototypes) do
    if item.fuel_value > 0 then
      fuel_list[item.name] = item.fuel_value/1000000
    end
    if item.ammo_type then
      if not ammo_list[item.ammo_type.category] then ammo_list[item.ammo_type.category] = {} end
      ammo_list[item.ammo_type.category][item.name]=1
    end
  end
  return {ammo = ammo_list, fuel = fuel_list}
end

function autofill.register_player_data(player_index)
  local player = game.players[player_index]
  global.player_data[player_index] = {
    enabled = false,
    fuel = {
      ["fuel-all"] = table.deepcopy(autofill.default_items.fuel)
    },
    ammo = {
      table.deepcopy(autofill.default_items.ammo),
    },
    sets = table.deepcopy(autofill.default_sets)
  }
    autofill.gui.init(player)
end

function autofill.register_force_data(force_name)
  if not global.force_data[force_name] then
    global.force_data[force_name] = {
      enabled = true,
      sets = {},
    }
  end
end

function autofill.toggle_paused(player_index)
  local pdata=global.player_data[player_index]
  pdata.enabled = not pdata.enabled
  autofill.gui.toggle_paused(game.players[player_index], pdata.enabled)
end

-------------------------------------------------------------------------------
--[[autofill events]]--
--Player created, set up tables, enable GUI if needed.
function autofill.on_player_created(event)
  doDebug("on_player_created "..event.player_index)
  autofill.register_player_data(event.player_index)
  autofill.register_force_data(game.players[event.player_index].force.name)
end
Event.register(defines.events.on_player_created, autofill.on_player_created)

function autofill.on_player_joined_game(event)
  doDebug("on_player_joined_game "..event.player_index)
end
Event.register(defines.events.on_player_joined_game, autofill.on_player_joined_game)

--Enable gui when automation research is finished.
function autofill.on_research_finished(event)
  if event.research.name == "automation" then
      for _, player in pairs(event.research.force.players) do
        autofill.gui.init(player, "automation")
    end
  end
end
Event.register(defines.events.on_research_finished, autofill.on_research_finished)


-------------------------------------------------------------------------------
--[[autofill init]]--
function autofill.on_init()
  for index, player in pairs(game.players) do
    autofill.register_player_data(index)
    autofill.register_force_data(player.force.name)
  end
  autofill.default_items = autofill.get_items()
  global.enabled=true
end
Event.register(Event.core_events.init, autofill.on_init)

function autofill.on_configuration_changed(event)
  if event.mod_changes ~= nil then
    --Any MOD has been changed/added/removed, including base game updates.
    --Do prototype updates here
    autofill.default_items = autofill.get_items()

    local changes = event.mod_changes[MOD.name]
    if changes ~= nil then -- This Mod has changed

      --Upgrade to 2.0.0-------------------------------------------------------
      if changes.old_version < "2.0.0" then
        doDebug("Autofill updated to 2.0.0")
        global = {}
        global.enabled=true
        global.player_data = {}
        global.force_data = {}
        global.config = _G.AF
        MOD.config = Config.new(global.config) -- We have global init, move config handler to global config
        autofill.on_init()
      end
      -------------------------------------------------------------------------
    end
  end
end
Event.register(Event.core_events.configuration_changed, autofill.on_configuration_changed)

function autofill.on_load()
end
Event.register(Event.core_events.load, autofill.on_load)


-------------------------------------------------------------------------------


return autofill
