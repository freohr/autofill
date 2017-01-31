local autofill = {}

local table_structures = require("lib.table_structures")

local function get_player_and_data(index)
    if game.players[index] then
        return game.players[index], global.players[index]
    end
end

local function init_force(force_name, overwrite)
    local fdata = global.forces
    if force_name then
        if not game.forces[force_name] then error("Invalid Force "..force_name) end
        if not fdata[force_name] or (fdata[force_name] and overwrite) then
            fdata[force_name] = table_structures.make_force_table(force_name)
        end
    else
        for name in pairs(game.forces) do
            if not fdata[name] or (fdata[name] and overwrite) then
                fdata[name] = table_structures.make_force_table(name)
            end
        end
    end
end

local function init_player(player_index, overwrite)
    local pdata = global.players
    if player_index then
        if not game.players[player_index] then error("Invalid Player") end
        if not pdata[player_index] or (pdata[player_index] and overwrite) then
            pdata[player_index] = table_structures.make_player_table(player_index)
        end
    else
        for index in pairs(game.players) do
            if not pdata[index] or (pdata[index] and overwrite) then
                pdata[index] = table_structures.make_player_table(index)
            end
        end
    end
end

local function on_player_created(event)
    init_player(event.player_index)
end
Event.register(defines.events.on_player_created, on_player_created)

local function on_force_created(event)
    init_force(event.force.name)
end
Event.register(defines.events.on_force_created, on_force_created)

--luacheck: ignore on_player_force_changed
--Disabled, this event will be in .15
local function on_player_force_changed(event)
    local player, pdata = get_player_and_data(event.player_index)
    pdata.force = player.force.name
    init_force(event.force.name)
    table_structures.set_player_metatables(pdata)
end
--Event.register(defines.events.on_player_force_changed, on_player_force_changed)

function autofill.on_load()
    if global.players then
        for index in pairs(global.players) do
            table_structures.set_player_metatables(global.players[index])
        end
    end
    if global.forces then
        for name in pairs(global.forces) do
            table_structures.set_force_metatables(global.forces[name])
        end
    end
end
Event.register(Event.core_events.load, autofill.on_load)
--Called ONCE, When loading into an world containing this mod. Does not get called if on_init is run.

function autofill.init()
    global.enabled = true
    global.global_sets = table_structures.make_global_sets()
    global.forces = {}
    init_force()
    global.players = {}
    init_player()
end
return autofill
