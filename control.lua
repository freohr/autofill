require("stdlib.loader")

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
MOD.log = require("stdlib.debug.debug")

--Generate any custom events
Event.reset_mod = script.generate_event_name()
Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
Event.death_events = {defines.events.on_preplayer_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}

-------------------------------------------------------------------------------

if MOD.config.DEBUG then
    MOD.log("Debug mode enabled")
    require("stdlib.debug.quickstart")
end

--Script Requires, The meat and potatatos of autofill
--luacheck: globals autofill
autofill = require("autofill")

--Add the remote interface.
remote.add_interface(MOD.interface, require("interface"))
