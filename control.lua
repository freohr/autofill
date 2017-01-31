require("stdlib/loader")

--Set up default MOD global variables.
--These "globals" are not stored in saves
MOD = {}
MOD.name = "autofill"
MOD.version = "2.0.0"
MOD.fullname = "AutoFill"
MOD.interface = "af"
MOD.path = "__"..MOD.name.."__"
MOD.config = require("config")
MOD.logfile = Logger.new(MOD.fullname, "log", MOD.config.DEBUG or false, {log_ticks = true, file_extension="log"})
MOD.logfile.file_name = MOD.logfile.file_name:gsub("logs/", "", 1)

--Generate any custom events
Event.reset_mod = script.generate_event_name()
Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
Event.death_events = {defines.events.on_preplayer_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}

-------------------------------------------------------------------------------
function MOD.log(msg, level)
    level = math.max(level or 0, ((global and global.config and global.config.LOGLEVEL) or MOD.config.LOGLEVEL or 0))
    if (level > 0) then
        if (level >= 1) then
            if type(msg) == "table" then
                MOD.logfile.log(serpent.block(msg, {comment=false}))
            else
                MOD.logfile.log(tostring(msg))
            end
        end
        if (level >= 2) and game then
            game.print(MOD.fullname .. ": " .. table.tostring(msg))
        end
    end
end

if MOD.config.DEBUG then
    MOD.log("Debug mode enabled")
    QS = MOD.config.quickstart --luacheck: ignore QS
    require("stdlib/debug/quickstart")
end

--Script Requires, The meat and potatatos of autofill
--luacheck: globals autofill
autofill = require("autofill.autofill")


-------------------------------------------------------------------------------
--[[INIT FUNCTIONS]]--
local changes = require("changes")
Event.register(Event.core_events.configuration_changed, changes.on_configuration_changed)
--Called ONCE, each time any mod (including base) is add/removed or version # changes.
--Called AFTER, on_init when installed into existing game.

function MOD.on_init()
    MOD.log("Init: Starting Install")
    global = {}
    global.config = table.deepcopy(MOD.config)
    global._changes = changes.on_init(game.active_mods[MOD.name] or MOD.version)
    autofill.init()
    MOD.log("Init: Install Complete", 2)
end
Event.register(Event.core_events.init, MOD.on_init)
--Called ONCE, when mod is installed to a new or existing world. Does not get called on subsequent loads

--Add the remote interface.
remote.add_interface(MOD.interface, require("interface"))
