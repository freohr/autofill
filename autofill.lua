--local Verify = require("autofill.verify")

local function get_player_and_data(index)
    if game.players[index] then
        return game.players[index], global.players[index]
    end
end

local autofill = {}

autofill.sets = require("autofill.sets")

function autofill.init_force(force_name, overwrite)
    local fdata = global.forces or {}
    if force_name then
        if not game.forces[force_name] then error("Invalid Force "..force_name) end
        if not fdata[force_name] or (fdata[force_name] and overwrite) then
            fdata[force_name] = autofill.sets.force.new(force_name)
        end
    else
        for name in pairs(game.forces) do
            if not fdata[name] or (fdata[name] and overwrite) then
                fdata[name] = autofill.sets.force.new(name)
            end
        end
    end
    return fdata
end

function autofill.init_player(player_index, overwrite)
    local pdata = global.players or {}
    if player_index then
        if not game.players[player_index] then error("Invalid Player") end
        if not pdata[player_index] or (pdata[player_index] and overwrite) then
            pdata[player_index] = autofill.sets.player.new(player_index)
        end
    else
        for index in pairs(game.players) do
            if not pdata[index] or (pdata[index] and overwrite) then
                pdata[index] = autofill.sets.player.new(index)
            end
        end
    end
    return pdata
end
-------------------------------------------------------------------------------
--[[Hotkeys]]--
-------------------------------------------------------------------------------
function autofill.hotkey_fill(event)
    local entity = game.players[event.player_index].selected
    local pdata = global.player_data[event.player_index]
    --local set = (pdata.sets[entity.name] or global.default_sets[entity.name])
    if entity and global.enabled and pdata.enabled then
        local set = pdata.sets.fill_sets[entity.name]
        if set then autofill.fill_entity(entity, pdata, set) end
    end
end
script.on_event("autofill-hotkey-fill", autofill.hotkey_fill)

function autofill.toggle_paused(event)
    local player, pdata = game.players[event.player_index], global.players[event.player_index]
    pdata.enabled = not pdata.enabled
    --autofill.gui.toggle_paused(game.players[event.player_index], pdata.paused)
    if pdata.enabled then
        player.print({"autofill.toggle-enabled-on"})
    else
        player.print({"autofill.toggle-enabled-off"})
    end
end
script.on_event("autofill-toggle-paused", autofill.toggle_paused)

function autofill.toggle_limits(event)
    local player, pdata = game.players[event.player_index], global.players[event.player_index]
    pdata.limits = not pdata.limits
    if pdata.limits then
        player.print({"autofill.toggle-limits-on"})
    else
        player.print({"autofill.toggle-limits-off"})
    end
end
script.on_event("autofill-toggle-limits", autofill.toggle_limits)

function autofill.toggle_groups(event)
    local player, pdata = game.players[event.player_index], global.players[event.player_index]
    pdata.groups = not pdata.groups
    if pdata.groups then
        player.print({"autofill.toggle-groups-on"})
    else
        player.print({"autofill.toggle-groups-off"})
    end
end
script.on_event("autofill-toggle-groups", autofill.toggle_groups)

-------------------------------------------------------------------------------
--[[Events]]--
-------------------------------------------------------------------------------
local on_built_entity = require("autofill.on_built_entity")
Event.register(defines.events.on_built_entity, on_built_entity)

local function on_player_created(event)
    autofill.init_player(event.player_index)
    for _, msg in pairs(global._mess_queue) do
        game.print(msg)
    end
    global._mess_queue = nil
    game.write_file(MOD.fullname.."/global.lua", serpent.block(global, {comment=false, sparse=true, compact=true, name="global", indent=" "}))
end
Event.register(defines.events.on_player_created, on_player_created)

local function on_force_created(event)
    autofill.init_force(event.force.name)
end
Event.register(defines.events.on_force_created, on_force_created)

--This event will be available in .15
local function on_player_changed_force(event) --luacheck: ignore on_player_changed_force
    local player, pdata = get_player_and_data(event.player_index)
    pdata.force = player.force.name
    autofill.init_force(event.force.name)
    autofill.sets.mt.set_player_metatables(pdata)
end
--Event.register(defines.events.on_player_changed_force, on_player_changed_force)

-------------------------------------------------------------------------------
--[[Init]]--
-------------------------------------------------------------------------------
local function on_load()
    if global.players then
        for index in pairs(global.players) do
            autofill.sets.mt.set_player_metasets(global.players[index])
        end
    end
    if global.forces then
        for name in pairs(global.forces) do
            autofill.sets.mt.set_force_metasets(global.forces[name])
        end
    end
end
Event.register(Event.core_events.load, on_load)

local changes = require("autofill.changes")
Event.register(Event.core_events.configuration_changed, changes.on_configuration_changed)

function MOD.on_init()
    MOD.log("Init: Starting Install")
    global = {}
    global.config = table.deepcopy(MOD.config.control)
    global._changes = changes.on_init(game.active_mods[MOD.name] or MOD.version)
    global.enabled = true
    global.sets = autofill.sets.global.new()
    global.forces = autofill.init_force()
    global.players = autofill.init_player()
    MOD.log("Installation Complete", 2)
end
Event.register(Event.core_events.init, MOD.on_init)

return autofill
