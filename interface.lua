------------------------------------------------------------------------------------------
--[[REMOTE INTERFACES]]-- Command Line and access from other mods is enabled here.
--luacheck: globals autofill
local interface = {}

interface.console = require("stdlib/debug/console")

--Dump the "global" to logfile
function interface.log_save_global(name)
    if name and type(name) == "string" then
        game.write_file(MOD.fullname.."/global.lua", serpent.block(global[name], {comment=false, sparse=true, compact=true, name="global."..name, indent="    "}))
    else
        game.write_file(MOD.fullname.."/global.lua", serpent.block(global, {comment=false, sparse=true, compact=true, name="global", indent="    "}))
    end
end

--Dump the MOD data to logfile
function interface.log_MOD_global(name)
    if name and type(name) == "string" then
        game.write_file(MOD.fullname.."/MOD.lua", serpent.block(MOD[name], {comment=false, sparse=true, compact=true, name="global."..name, indent="    "}))
    else
        game.write_file(MOD.fullname.."/MOD.lua", serpent.block(MOD, {comment=false, sparse=true, compact=true, name="global", indent="    "}))
    end
end

--Dump the MOD data to logfile
function interface.log_default_sets(name)
    if name and type(name) == "string" then
        game.write_file(MOD.fullname.."/default_sets.lua", serpent.block(autofill.sets.default[name], {comment=false, sparse=true, compact=true, name="global."..name, indent="    "}))
    else
        game.write_file(MOD.fullname.."/default_sets.lua", serpent.block(autofill.sets.default, {comment=false, sparse=true, compact=true, name="global", indent="    "}))
    end
end

function interface.config(key, value, silent)
    local config = Config.new(global.config)
    local level = (silent and 1) or 2
    if key then
        if key == "reset" then
            global.config = table.deepcopy(MOD.config.control)
            MOD.log("Reset config to default.", level)
            return true
        end
        --key=string.upper(key)
        if config.get(key) ~= nil then
            if value ~= nil then
                config.set(key, value)
                local val=config.get(key)
                MOD.log("New value for '" .. key .. "' is " .. "'" .. tostring(val) .."'", level)
                return val-- all is well
            else --value nil
                local val = config.get(key)
                MOD.log("Current value for '" .. key .. "' is " .. "'" .. tostring(val) .."'", level)
                return val
            end
        else --key is nill
            MOD.log("Config '" .. key .. "' does not exist", level)
            return nil
        end
    else
        if not silent then
            MOD.log("Config requires a key name", level)
            MOD.log(global.config, level)
        end
        return nil
    end
end

-------------------------------------------------------------------------------
--[[Reset functions]]
--Complete reset of the mod. Wipes everything.
interface.reset_mod = function()
    autofill.on_init()
    MOD.log(MOD.name .. " Reset Complete", 2)
end

-------------------------------------------------------------------------------
--[[Toggle functions]]
interface.toggle_or_set_global_enabled = autofill.globals.toggle_paused
interface.toggle_or_set_player_enabled = autofill.players.toggle_paused

-------------------------------------------------------------------------------
--[[Insert functions]]

function interface.insert_player_set()
end
function interface.insert_force_set()
end
function interface.insert_global_set()
end

-------------------------------------------------------------------------------
--[[creative-mode-functions]]

local function register_cm_interface(disable)
    --Register with creative-mode for easy testing
    if remote.interfaces["creative-mode"] and remote.interfaces["creative-mode"]["register_remote_function_to_modding_ui"] then
        MOD.log("Registering with Creative Mode")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "log_save_global")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "log_MOD_global")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "log_default_sets")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "reset_mod")
        --remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "verify_saved_sets")
        remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "console")
        if disable then interface.creative_mode_register = nil end
    end
end

function interface.creative_mode_register()
    register_cm_interface()
end
register_cm_interface(true)

return interface
