------------------------------------------------------------------------------------------
--[[REMOTE INTERFACES]]-- Command Line and access from other mods is enabled here.
--luacheck: globals autofill
local table_structures = require("lib.table_structures")
local interface = {}

--Dump the "global" to console and logfile
function interface.print_global(name)
    if name and type(name) == "string" then
        MOD.log(global[name], 2)
        game.write_file(MOD.fullname.."/global.lua", serpent.block(global[name], {comment=false, sparse=true}))
    else
        MOD.log(global, 2)
        game.write_file(MOD.fullname.."/global.lua", serpent.block(global, {comment=false, sparse=true}))
    end
end

--Complete reset of the mod. Wipes everything.
function interface.reset_mod()
    MOD.on_init()
    MOD.log(MOD.name .. " Reset Complete", 2)
end

function interface.reset_player(player, all)
    if all then
        autofill.init_player(nil, true)
    else
        autofill.init_player(player.index, true)
    end
end

function interface.reset_force(force, all)
    if all then
        autofill.init_force(nil, true)
    else
        if force and type(force) == "table" then force = force.name end
        autofill.init_force(force, true)
    end
end

function interface.reset_to_defualt_sets(type, player_or_force)
    MOD.log("reset_to_default_sets")
    autofill.verify_default_sets()
    if type == "all" or type == "global" then
        global.global_sets = table_structures.make_global_sets()
    end
    if type =="all" or type == "force" then
        if player_or_force then
            if type(player_or_force) == "table" and player_or_force.valid then player_or_force = player_or_force.name end
            --reset for force
        else
            --reset all forces
        end
    end
    if type == "all" or type == "player" then
        if player_or_force then
            if type(player_or_force) == "table" and player_or_force.valid then
                player_or_force = player_or_force.index
            elseif type(player_or_force) == "string" then
                player_or_force = game.players[player_or_force].index
            end
            table_structures.reset_player_sets(player_or_force)
        else
            for index in pairs(game.players) do
                table_structures.reset_player_sets(index)
            end
        end
    end
end

function interface.config(key, value, silent)
    local config = Config.new(global.config)
    local level = (silent and 1) or 2
    if key then
        if key == "reset" then
            global.config = MOD.config
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

function interface.toggle_or_set_player_enabled(player, enabled)

    --player = Game.get_valid_player(player)
    if player and player.valid then
        if global.players[player.index] then
            if enabled ~= nil then
                global.players[player.index].enabled = enabled
                return enabled
            else
                global.players[player.index].enabled = not global.players[player.index].enabled
                return global.players[player.index].enabled
            end
        end
    end
end

function interface.toggle_or_set_global_enabled(enabled)
    if enabled ~= nil then
        global.enabled = enabled
        return enabled
    else
        global.enabled = not global.enabled
        return global.enabled
    end
end

function interface.insert_personal_set()
end
function interface.insert_force_set()
end
function interface.insert_global_set()
end

interface.console = require("stdlib/debug/console")

--Register with creative-mode for easy testing
if remote.interfaces["creative-mode"] and remote.interfaces["creative-mode"]["register_remote_function_to_modding_ui"] then
    MOD.log("Registering with Creative Mode")
    remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "print_global")
    remote.call("creative-mode", "register_remote_function_to_modding_ui", MOD.interface, "console")
end

return interface
