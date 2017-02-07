-------------------------------------------------------------------------------
--[[sets.lua: Defines all set and table data]]--
-------------------------------------------------------------------------------
--luacheck: globals autofill
--game.print(global.players[1].sets.fill_sets["stone-furnace"].group)
local sets = {}

-------------------------------------------------------------------------------
--[[Local Functions]]--
-------------------------------------------------------------------------------

local function raw_merge(tblA, tblB, safe_merge)
    if not tblB then
        return tblA
    end
    if safe_merge then
        for k, v in pairs(tblB) do
            if not rawget(tblA, k) then
                rawset(tblA, k, v)
            end
        end
    else
        for k, v in pairs(tblB) do
            MOD.log(v)
            rawset(tblA, k, v)
        end
    end
    return tblA
end

local prequire = function(file)
    local ok, status = pcall(require, file)
    if not ok then return {} end
    return status
end

local get_default_sets = function(set_type, scope)
    local set = table.deepcopy(sets["default_"..set_type][scope])
    return set
end

-- local reset_to_default_sets = function(set_tables)
-- --local meta_fill_sets = getmetatable(set_tables.fill_sets)
-- --local meta_item_sets = getmetatable(set_tables.item_sets)
-- set_tables.fill_sets = setmetatable(get_default_sets("fill_sets", set_tables.type), getmetatable(set_tables.fill_sets))
-- set_tables.item_sets = setmetatable(get_default_sets("item_sets", set_tables.type), getmetatable(set_tables.item_sets))
-- --setmetatable(set_tables.fill_sets, meta_fill_sets)
-- --setmetatable(set_tables.item_sets, meta_item_sets)
-- end

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
    global = prequire("default-sets.global-fill-sets"),
    force = prequire("default-sets.force-fill-sets"),
    player = prequire("default-sets.player-fill-sets"),
}

sets.default_item_sets = {
    global = prequire("default-sets.global-item-sets"),
    force = prequire("default-sets.force-item-sets"),
    player = prequire("default-sets.player-item-sets"),
}

sets.get_item_sets_from_prototypes = function ()
    MOD.log("Retrieving default item sets from prototypes", 1)
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

sets.verify_saved_fill_sets = function(set, set_name)
    for entity_name in pairs(set) do
        if not _valid_entities(nil, entity_name, set_name) then
            rawset(set, entity_name, nil)
        end
    end
end

sets.verify_saved_item_sets = function(set, set_name)
    for category, items in pairs(set) do
        for item_name, _ in pairs(items) do
            if not _valid_items(nil, item_name, set_name) then
                rawset(set[category], item_name, nil)
            end
        end
    end
end

--Automaticly runs in on_configuration_changed
sets.update_and_verify_saved_sets = function (safe_merge)
    safe_merge = false
    MOD.log("Updating and Verifying all saved sets", 1)
    --Merge all then verify
    --
    -- raw_merge(global.sets.fill_sets, sets.default_fill_sets.global, safe_merge)
    -- raw_merge(global.sets.item_sets, sets.default_item_sets.global, safe_merge)
    -- if global.config.make_item_sets_from_prototypes then
    --     raw_merge(global.sets.item_sets, sets.get_item_sets_from_prototypes(), true)
    -- end
    -- sets.verify_saved_fill_sets(global.sets.fill_sets, "global_fill_sets")
    -- sets.verify_saved_item_sets(global.sets.item_sets, "global_item_sets")

    for _, force in pairs(global.forces) do
        raw_merge(force.sets.fill_sets, sets.default_fill_sets.force, safe_merge)
        --raw_merge(force.sets.item_sets, sets.default_item_sets.force, safe_merge)
        --sets.verify_saved_fill_sets(force.sets.fill_sets, "force_fill_sets")
        --sets.verify_saved_item_sets(force.sets.item_sets, "force_item_sets")
    end

    -- for _, player in pairs(global.players) do
    --     raw_merge(player.sets.fill_sets, sets.default_fill_sets.player, safe_merge)
    --     raw_merge(player.sets.item_sets, sets.default_item_sets.player, safe_merge)
    --     sets.verify_saved_fill_sets(player.sets.fill_sets, "player_fill_sets")
    --     sets.verify_saved_item_sets(player.sets.item_sets, "player_item_sets")
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
        table.merge(item_sets, sets.get_item_sets_from_prototypes())
    end
    return {
        type = "global",
        fill_sets = fill_sets,
        item_sets = item_sets,
    }
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
    sets.mt.set_force_metasets(obj)
    return obj
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
    sets.mt.set_player_metasets(obj)
    return obj
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

sets.mt.set_force_metasets = function(data)
    setmetatable(data.sets.fill_sets, sets.mt.forces("fill_sets"))
    setmetatable(data.sets.item_sets, sets.mt.forces("item_sets"))
end

sets.mt.set_player_metasets = function(data)
    setmetatable(data.sets.fill_sets, sets.mt.players(data, "fill_sets"))
    setmetatable(data.sets.item_sets, sets.mt.players(data, "item_sets"))
end

return sets
