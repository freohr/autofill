-------------------------------------------------------------------------------
--[[sets.lua: Defines all set and table data]]--luacheck: globals autofill
-------------------------------------------------------------------------------
--game.print(global.players[1].sets.fill_sets["stone-furnace"].group)
local sets = {}

-------------------------------------------------------------------------------
--[[Local Functions]]--
-------------------------------------------------------------------------------
--Require default sets, return an empty table if the default doesn't exist or has errors
local prequire = function(file)
    local ok, status = pcall(require, file)
    if not ok then return {} end
    return status
end

-------------------------------------------------------------------------------
--[[Metatable Information]]--
-------------------------------------------------------------------------------
sets.mt = {}
--Create index from global to autofill.defaut
sets.mt.global = function (table_name)
    return {__index = sets.default[table_name]}
end
--Create index from global.force["force_name"] to global.sets
sets.mt.forces = function (table_name)
    return {__index = global.sets[table_name]}
end
--Create index from global.players[index] to global.forces[players[index].force]
sets.mt.players = function (data, table_name)
    local force = data.force or "player"
    return {__index = global.forces[force].sets[table_name]}
end
sets.mt.set_global_metasets = function(data)
    setmetatable(data.fill_sets, sets.mt.global("fill_sets"))
    setmetatable(data.item_sets, sets.mt.global("item_sets"))
end
sets.mt.set_force_metasets = function(data)
    setmetatable(data.sets.fill_sets, sets.mt.forces("fill_sets"))
    setmetatable(data.sets.item_sets, sets.mt.forces("item_sets"))
end
sets.mt.set_player_metasets = function(data)
    setmetatable(data.sets.fill_sets, sets.mt.players(data, "fill_sets"))
    setmetatable(data.sets.item_sets, sets.mt.players(data, "item_sets"))
end

-------------------------------------------------------------------------------
--[[Defaults]]--
-------------------------------------------------------------------------------
sets.default = {}
sets.default.fill_sets = prequire("default-sets.default-fill-sets")
sets.default.item_sets = prequire("default-sets.default-item-sets")

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

-------------------------------------------------------------------------------
--[[On Load]]--
-------------------------------------------------------------------------------
--Reestablish all metatables on load
sets.on_load = function()
    if global and global._changes["2.0.0"] then
        if global.config.make_default_sets_from_files then
            sets.mt.set_global_metasets(global.sets)
        end
        for name in pairs(global.forces) do
            sets.mt.set_force_metasets(global.forces[name])
        end
        for index in pairs(global.players) do
            sets.mt.set_player_metasets(global.players[index])
        end
    end
end


return sets
