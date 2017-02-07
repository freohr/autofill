--[[HOW TO]]--[[

Fill and Item sets can be pre-defined for global/force/player usage. Sets are
automaticly updated and verified during on_init or on_configuration_changed. To
read any changes to these files without changing mod version numbers you will
have to run:
/c remote.call("af", "verify_saved_sets")

These are available globaly for everyone. If there is not a set by the same name
in the player or force table then sets from global are used.
global-fill-sets.lua
global-item-sets.lua

These are available for all forces. If there is not a set by the same name
in the player table then sets from force are used.
force-fill-sets.lua
force-item-sets.lua

These will be available to all players.
player-fill-sets.lua
player-item-sets.lua

--]]
