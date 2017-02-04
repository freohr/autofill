-------------------------------------------------------------------------------
--[[sets.lua: Defines all set and table data]]--
-------------------------------------------------------------------------------
--luacheck: globals autofill
--game.print(global.players[1].sets.fill_sets.boiler.group)
local sets = {}

-------------------------------------------------------------------------------
--[[Local Functions]]--
-------------------------------------------------------------------------------
local get_default_sets = function(set_type, scope, ignore_config)
    local set = {}
    if global.config["make_default_"..set_type] or ignore_config then
        set = table.deepcopy(sets["default_"..set_type][scope])
    end
    return set
end

local reset_to_default_sets = function(set_tables)
    local meta_fill_sets = getmetatable(set_tables.fill_sets)
    local meta_item_sets = getmetatable(set_tables.item_sets)
    set_tables.fill_sets = get_default_sets("fill_sets", set_tables.type)
    set_tables.item_sets = get_default_sets("fill_sets", set_tables.type)
    setmetatable(set_tables.fill_sets, meta_fill_sets)
    setmetatable(set_tables.item_sets, meta_item_sets)
end

local _valid_items = function(_, k, cat, set_name)
    if game.item_prototypes[k] then
        return true
    else
        MOD.log((set_name or "").." item_sets - Removing: '"..k.."' from '"..cat.."' - Invalid item", 1)
    end
end

local _valid_entities = function (_, k, set_name)
    if game.entity_prototypes[k] then
        return true
    else
        MOD.log((set_name or "").." fill_sets - Removing: '"..k.."' - Invalid entity", 1)
    end
end

-------------------------------------------------------------------------------
--[[Defaults]]--
-------------------------------------------------------------------------------
sets.default_fill_sets = {
    global = require("default-sets.global-fill-sets"),
    force = require("default-sets.force-fill-sets"),
    player = require("default-sets.player-fill-sets"),
}
sets.default_item_sets = {
    global = require("default-sets.global-item-sets"),
    force = require("default-sets.force-item-sets"),
    player = require("default-sets.player-item-sets"),
}
sets.verify_default_sets = function()
    MOD.log("Verifying all default fill_sets", 1)
    for name, set in pairs(sets.default_fill_sets) do
        sets.default_fill_sets[name] = table.filter(set, _valid_entities, name)
    end
    MOD.log("Verifying all default item_sets", 1)
    for name, set in pairs(sets.default_item_sets) do
        for category, items in pairs(set) do
            set[category] = table.filter(items, _valid_items, category, name)
        end
    end
end
sets.verify_saved_sets = function()
end
sets.get_item_sets_from_prototypes = function ()
    local item_sets = {}
    item_sets["fuel-high"] = {}
    item_sets["fuel-all"] = {}

    -- set the value of coal for fuel fuel_high table
    local min_high_fuel_value = game.item_prototypes["coal"] and game.item_prototypes["coal"].fuel_value or 8000000
    --Get Ammo's and Fuels
    for _, item in pairs(game.item_prototypes) do
        --Build fuel-all and fuel-high tables
        if item.fuel_value > 0 then
            item_sets["fuel-all"][item.name] = item.fuel_value/1000000
            if item.fuel_value >= min_high_fuel_value then
                item_sets["fuel-high"][item.name] = item.fuel_value/1000000
            end
        end
        --Build Ammo Category tables
        if item.ammo_type then
            item_sets[item.ammo_type.category] = item_sets[item.ammo_type.category] or {}
            item_sets[item.ammo_type.category][item.name]=1
        end
    end
    --increase priority of piercing bullets:
    if item_sets["bullet"] and item_sets["bullet"]["piercing-rounds-magazine"] then
        item_sets["bullet"]["piercing-rounds-magazine"]=10
    end
    return item_sets
end

--Automaticly runs in on_configuration_changed
sets.verify_saved_sets = function ()
    local _clean_set = function(v, k, good)
    end
    MOD.log("Verifying all saved sets.")

    if global.config.make_default_fill_sets then
        table.raw_merge(global.sets.fill_sets, sets.default_fill_sets.global)
        for _, force in pairs(global.forces) do
            table.raw_merge(force.sets.fill_sets, sets.default_fill_sets.force)
        end
        for _, player in pairs(global.players) do
            table.raw_merge(player.sets.fill_sets, sets.default_fill_sets.player)
        end
    end


    for entity_name in pairs(global.sets.fill_sets) do
        if not _valid_entities(nil, entity_name, "global_fill_sets") then
            rawset(global.sets.fill_sets, entity_name, nil)
        end
    end


local global_sets = global.sets
    -- for name, fdata in pairs(global.forces) do
    -- fdata.fill_sets = Verify.fill_sets(fdata.fill_sets, "force ".. name)
    -- end
    -- for i, pdata in pairs(global.players) do
    -- pdata.fill_sets = Verify.fill_sets(pdata.fill_sets, "player "..i)
    -- end
end

-------------------------------------------------------------------------------
--[[Global Sets]]--
-------------------------------------------------------------------------------
sets.global = {}
sets.global.new = function()
    sets.verify_default_sets()
    local fill_sets = get_default_sets("fill_sets", "global")
    local item_sets = get_default_sets("item_sets", "global")
    if global.config.make_item_sets_from_prototypes then
        table.merge(item_sets, autofill.get_item_sets_from_prototypes())
    end
    return {
        type = "global",
        fill_sets = fill_sets,
        item_sets = item_sets,
    }
end
sets.global.reset = function(set_tables)
    reset_to_default_sets(set_tables)
end

-------------------------------------------------------------------------------
--[[Force Sets]]--
-------------------------------------------------------------------------------
sets.force = {}
sets.force.new = function(force_name)
    local obj = {
        index = force_name,
        sets = {
            type = "force",
            fill_sets = get_default_sets("fill_sets", "force"),
            item_sets = get_default_sets("item_sets", "force"),
        },
    }
    sets.set_force_metasets(obj)
    return obj
end
sets.force.reset = function(set_tables)
    reset_to_default_sets(set_tables)
end

-------------------------------------------------------------------------------
--[[Player Sets]]--
-------------------------------------------------------------------------------
sets.player = {}
sets.player.new = function(player_index)
    local obj = {
        index = player_index,
        name = game.players[player_index].name,
        force = game.players[player_index].force.name,
        sets = {
            type = "player",
            fill_sets = get_default_sets("fill_sets", "player"),
            item_sets = get_default_sets("item_sets", "player"),
        },
        limits = true,
        groups = true,
        enabled = true,
    }
    sets.set_player_metasets(obj)
    return obj
end
sets.player.reset = function(set_tables)
    reset_to_default_sets(set_tables)
end

-------------------------------------------------------------------------------
--[[Metatable Information]]--
-------------------------------------------------------------------------------
sets.mt = {}
sets.mt.forces = function (table_name)
    return {__index = global.sets[table_name]}
end
sets.mt.players = function (set, table_name)
    local force = set.force or "player"
    return {__index = global.forces[force].sets[table_name]}
end

sets.set_force_metasets = function(data)
    setmetatable(data.sets.fill_sets, sets.mt.forces("fill_sets"))
    setmetatable(data.sets.item_sets, sets.mt.forces("item_sets"))
end

sets.set_player_metasets = function(data)
    setmetatable(data.sets.fill_sets, sets.mt.players(data, "fill_sets"))
    setmetatable(data.sets.item_sets, sets.mt.players(data, "item_sets"))
end

return sets
