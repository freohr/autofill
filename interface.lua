------------------------------------------------------------------------------------------
--[[REMOTE INTERFACES]]-- Command Line and access from other mods is enabled here.
local Game = require("stdlib.game")
local interface = {}

function interface.printGlob(name, constant) --Dumps the global to player and logfile
  if name then
    doDebug(global[name], "debug")
    if constant then doDebug(MOD[name], "debug") end
  else
    doDebug(global, "debug")
    if constant then doDebug(MOD, "debug") end
  end
end

function interface.resetMod()
  doDebug(MOD.name .. " Reset in progress")
  MOD.on_init(true)
  doDebug(MOD.name .. " Reset Complete", true)
end

function interface.config(key, value, silent)
  if key then
    key=string.upper(key)
    if MOD.config.get(key) ~= nil then
      if value ~= nil then
        MOD.config.set(key, value)
        local val=MOD.config.get(key)
        if not silent then Game.print_all(MOD.n .. ": New value for '" .. key .. "' is " .. "'" .. tostring(val) .."'") end
        return val-- all is well
      else --value nil
        local val = MOD.config.get(key)
        if not silent then Game.print_all(MOD.n .. ": Current value for '" .. key .. "' is " .. "'" .. tostring(val) .."'") end
        return val
      end
    else --key is nill
      if not silent then Game.print_all(MOD.n ..": Config '" .. key .. "' does not exist") end
      return nil
    end
  else
    if not silent then Game.print_all(MOD.n .. ": Config requires a key name") end
    return nil
  end
end

interface.insertset = function(username, entityname, set)--this fuction is for inserting personal sets.
  username = isValidUser(username)
  if username and isValidEntity(entityname) and isValidSet(set) then
    global.personalsets[username][entityname] = set
  end
end

interface.addToDefaultSets = function(entityname, set)
  if isValidEntity(entityname) and isValidSet(set) then
    global.defaultsets[entityname] = set
  end
end

getDefaultSets = function()
  local sets = table.deepcopy(global.defaultsets)
  for entity_name, set in pairs(sets) do
    for i=1, #set do
      for name, array in pairs(global.item_arrays) do
        if global.defaultsets[entity_name][i] == array then
          set[i] = name
          break
        end
      end
    end
  end
  return sets
end

interface.setDefaultSets = function(sets)
  for entity_name, set in pairs(sets) do
    if not isValidSet(set) then
      return
    end
  end
  global.defaultsets = sets
end

interface.getBackupLog = function()
  local tbl = loader.getBackupLog()
  local block = table.concat(tbl, "\n")
  log(block)
end

interface.getItemArray = function(name)
  return global.item_arrays[name]
end

interface.setItemArray = function(name, new_array)
  if global.item_arrays[name] == nil then
    global.item_arrays[name] = new_array
  else -- replaces content of table without creating new table to maintain referers
    local old_array = global.item_arrays[name]
    local max = #old_array < #new_array and #new_array or #old_array
    for i=1, max do
      old_array[i] = new_array[i]
    end
  end
end

interface.logGlobal = function(key)
  key = key or "global"
  if _G[key] then
    log( serpent.block(_G[key]) )
  else
    globalPrint("Global not found.")
  end
end

-- interface.resetMod = function()
-- initMod(true)
-- end

interface.resetUser = function(setname, username)
  username = isValidUser(username)
  if username then
    if setname == "lite" then
      global.personalsets[username] = makePersonalLiteSets()
    else
      global.personalsets[username] = { active = true }
    end
  end
end

interface.toggleUsage = function(username)
  username = isValidUser(username)
  if username then
    if global.personalsets[username] then
      global.personalsets[username].active = not global.personalsets[username].active
    else
      global.personalsets[username] = { active = true }
    end
  end
end

interface.setUsage = function(username, toggle)
  username = isValidUser(username)
  if username then
    if global.personalsets[username] then
      --local oldmode=global.personalsets[username].active
      global.personalsets[username].active=toggle
      return not toggle
    end
  end
end

return interface
