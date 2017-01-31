--luacheck: globals autofill
--game.print(global.players[1].fill_sets.boiler.group)
local table_structures = {}

table_structures.mt = {}
table_structures.mt.forces = function (table_name)
    return {__index = global.global_sets[table_name]}
end
table_structures.mt.players = function (set, table_name)
    return {__index = global.forces[set.force][table_name]}
end

table_structures.make_global_sets = function()
    return {
        fill_sets = table.deepcopy(autofill.default_fill_sets.global_fill_sets),
        item_sets = table.deepcopy(autofill.default_item_sets.global_item_sets)
    }
end

table_structures.reset_force = function(force_name)
end
table_structures.make_force_table = function(force_name)
    local obj = {
        index = force_name,
        name = force_name,
        fill_sets = table.deepcopy(autofill.default_fill_sets.force_fill_sets),
        item_sets = table.deepcopy(autofill.default_item_sets.force_item_sets),
    }
    table_structures.set_force_metatables(obj)
    return obj
end

table_structures.reset_player_sets = function(player_index)
    local player, pdata = game.players[player_index], global.players[player_index]

    local meta_fill_sets = getmetatable(pdata.fill_sets)
    pdata.fill_sets = autofill.default_fill_sets.player_fill_sets
    if meta_fill_sets then setmetatable(pdata.fill_sets, meta_fill_sets) end

    local meta_item_sets = getmetatable(pdata.item_sets)
    pdata.item_sets = autofill.default_item_sets.player_item_sets
    if meta_item_sets then setmetatable(pdata.item_sets, meta_item_sets) end
end

table_structures.make_player_table = function(player_index)
    local obj = {
        index = player_index,
        name = game.players[player_index].name,
        force = game.players[player_index].force.name,
        fill_sets = table.deepcopy(autofill.default_fill_sets.player_fill_sets),
        item_sets = table.deepcopy(autofill.default_item_sets.player_item_sets),
        limits = true,
        groups = true,
        enabled = true,
    }
    table_structures.set_player_metatables(obj)
    return obj
end

table_structures.set_force_metatables = function(set)
    setmetatable(set.fill_sets, table_structures.mt.forces("fill_sets"))
    setmetatable(set.item_sets, table_structures.mt.forces("item_sets"))
end

table_structures.set_player_metatables = function(set)
    setmetatable(set.fill_sets, table_structures.mt.players(set, "fill_sets"))
    setmetatable(set.item_sets, table_structures.mt.players(set, "item_sets"))
end

return table_structures
