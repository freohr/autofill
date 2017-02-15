-------------------------------------------------------------------------------
--[[Force Sets]]--luacheck: globals autofill
-------------------------------------------------------------------------------
local forces = {}

forces.new = function(force_name)
    local obj = {
        index = force_name,
        sets = {
            type = "force",
            fill_sets = {},
            item_sets = {},
        },
    }
    autofill.sets.mt.set_force_metasets(obj)
    return obj
end

forces.init = function(force_name, overwrite)
    local fdata = global.forces or {}
    if force_name then
        if not game.forces[force_name] then error("Invalid Force "..force_name) end
        if not fdata[force_name] or (fdata[force_name] and overwrite) then
            fdata[force_name] = forces.new(force_name)
        end
    else
        for name in pairs(game.forces) do
            if not fdata[name] or (fdata[name] and overwrite) then
                fdata[name] = forces.new(name)
            end
        end
    end
    return fdata
end

forces.research_finished = function (event)
    if event.research.name == "automation" then
        for i, player in pairs(game.players) do
            if player.force == event.research.force then
                autofill.gui.init(player, global.players[i], event.research.name)
            end
        end
    end
end

return forces
