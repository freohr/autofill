--game.print(global.players[1].fill_sets.boiler.group)

local global_fill_sets = require("default-sets.global-fill-sets")
local force_fill_sets = require("default-sets.force-fill-sets")
local player_fill_sets = require("default-sets.player-fill-sets")
local Verify = require("lib.verify")

local table_structures = {}

table_structures.mt = {}
table_structures.mt.forces = function (table_name)
    return {__index = global.global_sets[table_name]}
end
table_structures.mt.players = function (set, table_name)
    return {__index = global.forces[set.force][table_name]}
end

table_structures.verify = function()
    MOD.log("Verifying default fill_sets")
    global_fill_sets = Verify.fill_sets(global_fill_sets)
    force_fill_sets  = Verify.fill_sets(force_fill_sets )
    player_fill_sets = Verify.fill_sets(player_fill_sets)
end

table_structures.make_global_sets = function()
    table_structures.verify()
    return {
        fill_sets = table.deepcopy(global_fill_sets),
        item_sets = {}
    }
end

table_structures.make_force_table = function(force_name)
    local obj = {
        index = force_name,
        name = force_name,
        fill_sets = table.deepcopy(force_fill_sets),
        item_sets = {},
    }
    table_structures.set_force_metatables(obj)
    return obj
end

table_structures.make_player_table = function(index)
    local obj = {
        index = index,
        name = game.players[index].name,
        force = game.players[index].force.name,
        fill_sets = table.deepcopy(player_fill_sets),
        item_sets = {},
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
