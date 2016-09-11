require "util"

MOD = { NAME = "Autofill", IF = "af" }






remote.add_interface(MOD.IF,
{
  insertset = function(username, entityname, set)--this fuction is for inserting personal sets.
    username = isValidUser(username)
    if username and isValidEntity(entityname) and isValidSet(set) then
      global.personalsets[username][entityname] = set
    end
  end,

  addToDefaultSets = function(entityname, set)
    if isValidEntity(entityname) and isValidSet(set) then
      global.defaultsets[entityname] = set
    end
  end,

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
  end,

  setDefaultSets = function(sets)
    for entity_name, set in pairs(sets) do
      if not isValidSet(set) then
        return
      end
    end
    global.defaultsets = sets
  end,

  getBackupLog = function()
    local tbl = loader.getBackupLog()
    local block = table.concat(tbl, "\n")
    log(block)
  end,

  getItemArray = function(name)
    return global.item_arrays[name]
  end,

  setItemArray = function(name, new_array)
    if global.item_arrays[name] == nil then
      global.item_arrays[name] = new_array
    else -- replaces content of table without creating new table to maintain referers
      local old_array = global.item_arrays[name]
      local max = #old_array < #new_array and #new_array or #old_array
      for i=1, max do
        old_array[i] = new_array[i]
      end
    end
  end,

  logGlobal = function(key)
    key = key or "global"
    if _G[key] then
      log( serpent.block(_G[key]) )
    else
      globalPrint("Global not found.")
    end
  end,

  resetMod = function()
    initMod(true)
  end,

  resetUser = function(setname, username)
    username = isValidUser(username)
    if username then
      if setname == "lite" then
        global.personalsets[username] = makePersonalLiteSets()
      else
        global.personalsets[username] = { active = true }
      end
    end
  end,

  toggleUsage = function(username)
    username = isValidUser(username)
    if username then
      if global.personalsets[username] then
        global.personalsets[username].active = not global.personalsets[username].active
      else
        global.personalsets[username] = { active = true }
      end
    end
  end,

	setUsage = function(username, toggle)
		username = isValidUser(username)
		if username then
			if global.personalsets[username] then
				--local oldmode=global.personalsets[username].active
				global.personalsets[username].active=toggle
				return not toggle
			end
		end
	end
})
