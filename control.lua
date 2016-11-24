--Require Config Settings
_G.AF = require("config")

--require Logger and Config libraries
require("stdlib.log.logger")
require("stdlib.config.config")

--Set up default MOD global variables. These "globals" are not stored in saves
MOD = {}
MOD.name = "autofill"
MOD.IF = "af"
MOD.path = "__"..MOD.name.."__"
MOD.config = Config.new(_G.AF) --Store in Mod global until we can switch to "global"
MOD.logfile = Logger.new(MOD.name, "info", true, {log_ticks = true})

require("stdlib.utils.debug") -- require debug functions (requires Mod.logfile be set)
require("stdlib.utils.utils")  -- string, table, time, colors
require("stdlib.event.event") --Event system
require("stdlib.gui.gui") --Gui system

--Generate any custom events
Event.reset_mod = script.generate_event_name()
Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
Event.death_events = {defines.events.on_preplayer_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}

-------------------------------------------------------------------------------
--[[CONTROL HELPERS]]--Helper functions for the control stage
--luacheck: globals Game

--Registers players, will overwrite data

-- local function register_player_data(player_index)
--   if player_index and Game.valid_player(player_index) then
--     global.player_data[player_index] = {}
--   else
--     for i, _ in pairs(game.players) do
--       global.player_data[i] = {}
--     end
--   end
-- end
--
-- --Registers forces, will overwrite data
-- local function register_force_data(force_name)
--   if force_name and Game.valid_force(force_name) then
--     global.force_data[force_name] = {}
--   else
--     for name, _ in pairs(game.forces) do
--       global.force_data[name] = {}
--     end
--   end
-- end

-------------------------------------------------------------------------------
--[[INIT FUNCTIONS]]-- Commonly used Init functions, Should be non-mod specific
-- as these are handled in in "scripts"

function MOD.on_init()
  doDebug("on_init: Started")

  --Set up global table
  global = {}
  global.player_data = {}
  global.force_data = {}
  global.config = _G.AF
  MOD.config = Config.new(global.config) -- We have global init, move config handler to global config
  doDebug("on_init: Complete")
end
Event.register(Event.core_events.init, MOD.on_init)
--Called ONCE, when mod is installed to a new or existing world. Does not get called on subsequent loads

function MOD.on_configuration_changed(event)
  if event.mod_changes ~= nil then
    doDebug("on_configuration_changed: version changes detected")
    --Any MOD has been changed/added/removed, including base game updates.
    local changes = event.mod_changes[MOD.name]
    if changes ~= nil then -- THIS Mod has changed
      doDebug(MOD.name .." Updated from ".. tostring(changes.old_version) .. " to " .. tostring(changes.new_version), true)
      --This mod has changed
    end
  end
end
Event.register(Event.core_events.configuration_changed, MOD.on_configuration_changed)
--Called ONCE, each time any mod (including base) is add/removed or version # changes.
--Called AFTER, on_init when installed into existing game.

function MOD.on_load()
  doDebug(" on_load")
  MOD.config = Config.new(global.config) -- We have global init, move config handler to global config
end
Event.register(Event.core_events.load, MOD.on_load)
--Called ONCE (in SP?), When loading into an world containing this mod. Does not get called if on_init is run.

--Script Requires, The meat and potatatos of autofill
--luacheck: globals autofill
autofill=require("autofill")

--Add the remote interface.
remote.add_interface(MOD.IF, require("interface"))
