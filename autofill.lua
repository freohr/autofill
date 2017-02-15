--Generate any custom events
Event.toggle_player_paused = script.generate_event_name()
Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
Event.death_events = {defines.events.on_preplayer_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died}

local autofill = {}
autofill.gui = require ("autofill.gui")
autofill.sets = require("autofill.sets")
autofill.globals = require("autofill.globals")
autofill.forces = require("autofill.forces")
autofill.players = require("autofill.players")


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
Event.register(defines.events.on_research_finished, autofill.forces.research_finished)

local on_built_entity = require("autofill.on_built_entity")
Event.register(defines.events.on_built_entity, on_built_entity)

local function on_player_created(event)
    autofill.players.init(event.player_index)
    for _, msg in pairs(global._mess_queue) do
        game.print(msg)
    end
    global._mess_queue = nil
    game.write_file(MOD.fullname.."/global.lua", serpent.block(global, {comment=false, sparse=true, compact=true, name="global", indent=" "}))
end
Event.register(defines.events.on_player_created, on_player_created)

Event.register(defines.events.on_force_created, function(event) autofill.forces.init(event.force.name) end)

--This event will be available in .15
--Event.register(defines.events.on_player_changed_force, autofill.players.change_force)

-------------------------------------------------------------------------------
--[[Init]]--
-------------------------------------------------------------------------------
Event.register(Event.core_events.load, autofill.sets.on_load)

local changes = require("autofill.changes")
Event.register(Event.core_events.configuration_changed, changes.on_configuration_changed)

function autofill.on_init()
    MOD.log("Init: Starting Install")
    global = autofill.globals.new()
    global._changes = changes.on_init(game.active_mods[MOD.name] or MOD.version)
    global.forces = autofill.forces.init()
    global.players = autofill.players.init()
    MOD.log("Installation Complete", 2)
end
Event.register(Event.core_events.init, autofill.on_init)

return autofill
