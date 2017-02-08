local priorities = {["qty"]="qty", ["max"]="max", ["min"]="min"}
--local inv = {ammo=defines.inventory.ammo, fuel=defines.inventory.fuel, main=defines.inventory.player_main, quickbar=defines.inventory.player_quickbar}

local function flying_text(line, color, pos, surface)
    color = color or defines.colors.red
    line = line or "missing text" --If we for some reason didn't pass a message make a message
    if not pos then
        for _, p in pairs(game.players) do
            p.surface.create_entity({name="flying-text", position=p.position, text=line, color=color})
        end
        return
    else
        if surface then
            surface.create_entity({name="flying-text", position=pos, text=line, color=color})
        end
    end
end

local function get_highest_value(tbl)
    for item, value in table.spairs(tbl, function(t,a,b) return t[b] < t[a] end) do
        if game.item_prototypes[item] then
            return item, value
        end
    end
    return false
end

--Increment the y position for flying text
local function increment_position(position)
    local x = position.x
    local y = position.y - 1
    return function ()
        y=y+1
        return {x=x, y=y}
    end
end

-- local function count_slots(tbl)
-- local categories = {}
-- for i=1, #tbl.slots do
-- local slot = tbl.slots[i]
-- if not categories[slot.type] then
-- categories[slot.type]=1
-- temp[#temp+1]=slot.category
-- else
-- categories[slot.category] = categories[slot.category] + 1
-- end
-- end
-- return categories
-- end

local function on_built_entity(event)
    local entity = event.created_entity
    local player, pdata = game.players[event.player_index], global.players[event.player_index]
    local set = pdata.sets.fill_sets[entity.name]
    if set and global.enabled and pdata.enabled then
        MOD.log("Fill set found for " .. entity.name, 0)

        --Increment y position everytime text_pos is called
        local text_pos = increment_position(entity.position)

        --local fuel_slots = pcall(#entity.get_inventory(defines.inventory.fuel))
        -- local duplicate_counts = {}

        --Get inventories
        local main_inventory = player.get_inventory(defines.inventory.player_main)
        local quickbar = player.get_inventory(defines.inventory.player_quickbar)
        local vehicle_inventory
        local ok, _ = pcall(function() vehicle_inventory = player.vehicle.get_inventory(defines.inventory.car_trunk) end)
        if not ok then vehicle_inventory = false end

        local slot_counts = {}
        --further divide amongst same type slot counts
        for _, slot in ipairs(set.slots) do
            slot_counts[slot.category] = slot_counts[slot.category] or 0 + 1
        end

        --Loop through each slot in the set.
        for _, slot in ipairs(set.slots) do
            local color = defines.colors.red -- Color for fying text
            local item = false -- The item to insert
            local item_count = 0 -- Total count of item in inventory and car inventory
            local insert_count = 0 -- Count of items to insert
            local group_count = 1 -- Num of items in the group. (Hand + Quickbar)

            --verify or set existing priority
            local priority = priorities[slot.priority] or "qty"

            --START Item Count --------------------------------------------------------
            --Get the item list from player or default if no player
            local item_list = pdata.sets.item_sets[slot.category]

            --No item list or item list is not a table.
            if not item_list or type(item_list) ~= "table" then
                flying_text({"autofill.invalid-category"}, color, text_pos(), entity.surface)
                MOD.log("Missing or invalid Category " ..(slot.category or "nil"), 1)
                goto break_out
            end

            if player.cheat_mode and global.config.sync_with_cheat_mode then
                item = get_highest_value(item_list)
                if item then item_count = 1000000 end
                MOD.log("Priority Cheat "..(item or "no-item").." count=" .. item_count, 0)
            elseif priority=="qty" then
                for item_name, _ in pairs(item_list) do
                    if game.item_prototypes[item_name] then
                        if (main_inventory.get_item_count(item_name) > item_count) or (vehicle_inventory and main_inventory.get_item_count(item_name) + vehicle_inventory.get_item_count(item_name) > item_count) then
                            item = item_name
                            item_count = (not vehicle_inventory and main_inventory.get_item_count(item_name) or main_inventory.get_item_count(item_name) + vehicle_inventory.get_item_count(item_name))
                        end
                    end
                end
                MOD.log("Priority qty "..(item or "no-item").." count=" .. item_count, 0)
            elseif priority == "max" then
                for item_name, _ in table.spairs(item_list, function(t,a,b) return t[b] < t[a] end) do
                    if game.item_prototypes[item_name] and main_inventory.get_item_count(item_name) > 0 or (vehicle_inventory and vehicle_inventory.get_item_count(item_name) > 0) then
                        item = item_name
                        item_count = main_inventory.get_item_count(item)
                        item_count = not vehicle_inventory and item_count or item_count + vehicle_inventory.get_item_count(item)
                        break
                    end
                end
                MOD.log("Priority max "..(item or "no-item").." count=" .. item_count, 0)
            elseif priority=="min" then
                for item_name, _ in table.spairs(item_list, function(t,a,b) return t[b] > t[a] end) do
                    if game.item_prototypes[item_name] and main_inventory.get_item_count(item_name) > 0 or (vehicle_inventory and vehicle_inventory.get_item_count(item_name) > 0) then
                        item = item_name
                        item_count = main_inventory.get_item_count(item)
                        item_count = not vehicle_inventory and item_count or item_count + vehicle_inventory.get_item_count(item)
                        break
                    end
                end
                MOD.log("Priority min "..(item or "no-item").." count=" .. item_count, 0)
            end

            if not item or item_count < 1 then
                local key_table=table.keys(item_list)
                if key_table[1] ~= nil and game.item_prototypes[key_table[1]] then
                    flying_text({"autofill.out-of-item", game.item_prototypes[key_table[1]].localised_name }, color, text_pos(), entity.surface)
                elseif key_table[1] ~= nil then
                    flying_text({"autofill.invalid-itemname", key_table[1]}, color, text_pos(), entity.surface)
                end
                goto break_out
            end
            --We now have an item, and a count of the amount of items we have.
            ----END Item Count--

            ----START Groups-------------------------------------------------------------
            --Divide stack between group items (only items in quickbar and hand are part of the group)
            --Get count in hands
            if set.group and pdata.groups then
                if player.cursor_stack.valid_for_read then
                    group_count = group_count + player.cursor_stack.count
                end
                for entity_name, set_table in pairs(pdata.sets) do
                    if type(set_table) == "table" and set_table.group == set.group then
                        group_count = group_count + quickbar.get_item_count(entity_name)
                    end
                end
                MOD.log("Group count = " .. group_count, 0)
            end
            --END Groups--

            local slot_count = slot_counts[slot.category] or 1 - 1
            if slot_count < 1 then slot_count = 1 end

            local stack_size = game.item_prototypes[item].stack_size
            local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
            insert_count = insert_count + min(max(1, min(item_count, floor(item_count / ceil(group_count / slot_count)))), (pdata.limits and slot.limit) or stack_size)
            MOD.log("Insert count = "..insert_count, 0)

            --Do insertion-------------------------------------------------
            local removed, inserted

            inserted = entity.insert({name=item, count=insert_count})
            if inserted > 0 then
                if vehicle_inventory then
                    removed = vehicle_inventory.remove({name=item, count=inserted})
                    if inserted > removed then
                        main_inventory.remove({name=item, count=inserted - removed})
                    end
                else
                    main_inventory.remove({name=item, count=inserted})
                end

                if inserted < stack_size then
                    color = defines.colors.yellow
                elseif insert_count >= stack_size then
                    color = defines.colors.green
                end

                if removed then
                    flying_text(
                        {
                            "autofill.insertion-from-vehicle",
                            inserted,
                            game.item_prototypes[item].localised_name,
                            removed, game.entity_prototypes[player.vehicle.name].localised_name
                        },
                        color, text_pos(), entity.surface
                    )
                else
                    flying_text({"autofill.insertion", inserted, game.item_prototypes[item].localised_name }, color, text_pos(), entity.surface)
                end
            end
            ::break_out::
        end
    end
end

return on_built_entity
