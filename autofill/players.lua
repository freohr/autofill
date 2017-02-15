-------------------------------------------------------------------------------
--[[Player Sets]]--luacheck: globals autofill
-------------------------------------------------------------------------------
local function get_player_and_data(index)
    if game.players[index] then
        return game.players[index], global.players[index]
    end
end

local players = {}

players.new = function(player_index)
    local obj = {
        index = player_index,
        name = game.players[player_index].name,
        force = game.players[player_index].force.name,
        sets = {
            type = "player",
            fill_sets = {},
            item_sets = {},
        },
        limits = true,
        groups = true,
        enabled = true,
    }
    autofill.gui.init(game.players[player_index], obj)
    autofill.sets.mt.set_player_metasets(obj)
    return obj
end

players.init = function(player_index, overwrite)
    local pdata = global.players or {}
    if player_index then
        if not game.players[player_index] then error("Invalid Player") end
        if not pdata[player_index] or (pdata[player_index] and overwrite) then
            pdata[player_index] = players.new(player_index)
        end
    else
        for index in pairs(game.players) do
            if not pdata[index] or (pdata[index] and overwrite) then
                pdata[index] = players.new(index)
            end
        end
    end
    return pdata
end

players.changed_force = function(event)
    local player, pdata = get_player_and_data(event.player_index)
    pdata.force = player.force.name
    autofill.init_force(event.force.name)
    autofill.sets.mt.set_player_metatables(pdata)
end

players.toggle_paused = function (player, enabled)
    if player and player.valid then
        local pdata = global.players[player.index]
        if pdata then
            if enabled ~= nil then
                pdata.enabled = enabled
                game.raise_event(Event.toggle_player_paused, {player_index = player.index, enabled=pdata.enabled})
                player.print({"autofill.toggle-enabled-"..tostring(pdata.enabled)})
                return enabled
            else
                pdata.enabled = not pdata.enabled
                game.raise_event(Event.toggle_player_paused, {player_index = player.index, enabled=pdata.enabled})
                player.print({"autofill.toggle-enabled-"..tostring(pdata.enabled)})
                return pdata.enabled
            end
        end
    end
end

return players
