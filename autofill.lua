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

------------------------------------------------------------------------------=
--[[Events]]
local function on_player_created(event)
    autofill.init_player(event.player_index)
    for _, msg in pairs(global._mess_queue) do
        game.print(msg)
    end
    global._mess_queue = nil
    game.write_file(MOD.fullname.."/global.lua", serpent.block(global, {comment=false, sparse=false}))
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
    autofill.tables.set_player_metatables(pdata)
end
--Event.register(defines.events.on_player_changed_force, on_player_changed_force)

function autofill.on_load()
    if global.players then
        for index in pairs(global.players) do
            autofill.sets.set_player_metasets(global.players[index])
        end
    end
    if global.forces then
        for name in pairs(global.forces) do
            autofill.sets.set_force_metasets(global.forces[name])
        end
    end
end
Event.register(Event.core_events.load, autofill.on_load)
--Called ONCE, When loading into a world containing this mod. Does not get called if on_init is run.

function autofill.init()
    global.enabled = true
    global.sets = autofill.sets.global.new()
    global.forces = autofill.init_force()
    global.players = autofill.init_player()
end
return autofill
