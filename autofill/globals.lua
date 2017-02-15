-------------------------------------------------------------------------------
--[[Global Sets]]--luacheck: globals autofill
-------------------------------------------------------------------------------
local globals = {}

globals.new = function()
    local obj = {
        enabled = true,
        index = "global",
        config = table.deepcopy(MOD.config.control),
        sets = {
            fill_sets = {},
            item_sets = {}
        }
    }
    if obj.config.make_item_sets_from_prototypes then
        table.raw_merge(obj.sets.item_sets, autofill.sets.get_item_sets_from_prototypes(), "safe")
    end
    if obj.config.make_default_sets_from_files then
        autofill.sets.mt.set_global_metasets(obj.sets)
    end
    return obj
end

globals.toggle_enabled = function(enabled)
    if enabled ~= nil then
        global.enabled = enabled
        return enabled
    else
        global.enabled = not global.enabled
        return global.enabled
    end
end

return globals
