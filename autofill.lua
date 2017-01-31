local meta_tables = {}
meta_tables.forces = function (table_name)
    return {__index = global.sets[table_name]}
end
meta_tables.players = function (player_index, table_name)
    return {__index = global.forces[game.players[player_index].force.name][table_name]}
end

local function get_player_and_data(player_index)
    return game.players[player_index], global.players[player_index]
end

function set_metatables()
end

local function init_global()
end

local function init_player(player_index)
    local pdata = global.players
    local get_table = function(index)
        return {
            index = index,
            fill_sets = {},
            item_sets = {},
            limits = true,
            groups = true,
            enabled = true,
        }
    end
    if player_index then
        if not game.players[player_index] then error("Invalid Player") end
        pdata[player_index] = make_table(player_index)
    else
        for _, player in pairs(game.players) do
            pdata[player_index] = make_table(player_index)
            setmetatable(pdata[player_index].fill_sets, meta_tables.players(player_index, "fill-sets"))
            setmetatable(pdata[player_index].item_sets, meta_tables.players(player_index, "item-sets"))
        end
    end

    local function init_force(force, overwrite)
    end

    local autofill = {}
    function autofill.init()
        global.sets = {
            fill_sets = {},
            item_sets = {},
        }

        global.forces = {}
        new_force_data()

        global.players = {}
        new_player_data()
        --set_metatables()
    end
