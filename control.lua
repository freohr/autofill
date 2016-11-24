--Config Requires
local config_data = require("config")
local Config=require("stdlib.config.config")
local Logger = require("stdlib.log.logger")

--MOD Setup
MOD = {}
MOD["name"] = "autofill"
MOD["n"] = "af"
MOD["false"] = true
MOD["config"] = Config.new(config_data)
MOD["logfile"] = Logger.new(MOD.name, "info", true, {log_ticks = true})
MOD["Event"]=require("stdlib.event.event")
MOD["registered"] = false
MOD["fileheader"] = "   vvvvvvvvvvvvvvvvvvvvvvvv--".. MOD.name .." Logging Started:--vvvvvvvvvvvvvvvvvvvvvvvv"

--Util Requires
require("stdlib.utils.utils")

--Script Requires
local scripts = {
  autofill=require("autofill")
}

-------------------------------------------------------------------------------
--[[CONTROL HELPERS]]--Helper functions for the control stage
local function step_through_scripts(name, event, reset)
  for _, script in pairs(scripts) do
    if script[name] then script[name](event, reset) end
  end
end

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

-------------------------------------------------------------------------------
--[[INIT FUNCTIONS]]--Commonly used Init functions

local function on_init(reset)
  doDebug("on_init: Started")
  global = {}
  global.config = config_data
  MOD.config = Config.new(global.config) -- We have global init, move config handler to global config
  all_players_init(MOD.reset)
  step_through_scripts("on_init", nil, reset)
  MOD.reset=false
  doDebug("on_init: Complete")
end
script.on_init(on_init)
--Called ONCE, when mod is installed to a new or existing world. Does not get called on subsequent loads

--global wrapper for on_init, used in interface
MOD.on_init = function(args) on_init(args) end

local function on_configuration_changed(event)
  if event.mod_changes ~= nil then
    doDebug("on_game_changed: version changes detected")
    local changes = event.mod_changes[MOD.name]
    if changes ~= nil then -- THIS Mod has changed
      doDebug(MOD.name .." Updated from ".. tostring(changes.old_version) .. " to " .. tostring(changes.new_version), true)
      step_through_scripts("on_configuration_changed", event)
      --Do Stuff Here if needed
    end
    MOD.reset=false
  end
end
script.on_configuration_changed(on_configuration_changed)
--Called ONCE, each time any mod (including base) is add/removed or version # changes.
--Called AFTER, on_init when installed into existing game.

local function on_load()
  doDebug(" on_load")
  MOD.config = Config.new(global.config) -- We have global init, move config handler to global config
  step_through_scripts("on_load")

end
script.on_load(on_load)
--Called ONCE (in SP?), When loading into an world containing this mod. Does not get called if on_init is run.

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

------------------------------------------------------------------------------------------
--[[PLAYER FUNCTIONS]]--Commonly used player functions

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

remote.add_interface(MOD.n, require("interface"))
