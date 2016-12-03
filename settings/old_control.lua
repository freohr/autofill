--luacheck: ignore
script.on_configuration_changed(function()
    initMod(false,true)
  end)

script.on_init(function()
    initMod(true)
  end)

function autoFill(entity, player, fillset)
  local textpos = entity.position
  local maininv = player.get_inventory(defines.inventory.player_main)

  local vehicleinv
  local ok, err = pcall(function() vehicleinv = player.vehicle.get_inventory(2) end)
  if not ok then vehicleinv = false end

  local quickbar = player.get_inventory(defines.inventory.player_quickbar)
  local array, item, count, groupsize, slots, totalitemcount, color, inserted, removed
  for i=1, #fillset do --? Item prototype check here?
    array = fillset[i]
    item = false
    count = 0
    color = RED

    if fillset.priority == order.itemcount then -- Pick item with highest count
      for j = 1, #array do
        if game.item_prototypes[array[j]] then
          if vehicleinv then
            if maininv.get_item_count(array[j]) + vehicleinv.get_item_count(array[j]) > count then
              item = array[j]
              count = maininv.get_item_count(array[j]) + vehicleinv.get_item_count(array[j])
            end
          else
            if maininv.get_item_count(array[j]) > count then
              item = array[j]
              count = maininv.get_item_count(array[j])
            end
          end
        end
      end
    elseif fillset.priority == order.opposite then --Pick last available item
      for j = #array, 1, -1 do
        if game.item_prototypes[array[j]] then
          if maininv.get_item_count(array[j]) > 0 or vehicleinv and vehicleinv.get_item_count(array[j]) > 0 then
            item = array[j]
            count = maininv.get_item_count(array[j])
            count = not vehicleinv and count or count + vehicleinv.get_item_count(array[j])
            break
          end
        end
      end
    else --Pick first available item
      for j = 1, #array do
        if game.item_prototypes[array[j]] then
          if maininv.get_item_count(array[j]) > 0 or vehicleinv and vehicleinv.get_item_count(array[j]) > 0 then
            item = array[j]
            count = maininv.get_item_count(array[j])
            count = not vehicleinv and count or count + vehicleinv.get_item_count(array[j])
            break
          end
        end
      end
    end

    if not item or count < 1 then
      if array[1] ~= nil and game.item_prototypes[array[1]] then
        text({"autofill.out-of-item", game.item_prototypes[array[1]].localised_name }, textpos, player.surface, color)
        textpos.y = textpos.y + 1
      end
    else
      -- Divide stack between group (only items in quickbar are part of group)
      local usegroups = global.personalsets[player.name].usegroups
      if usegroups == nil then usegroups = true end

      if fillset.group and usegroups then
        if player.cursor_stack.valid_for_read then
          groupsize = player.cursor_stack.count + 1
        else
          groupsize = 1
        end

        for k,v in pairs(global.personalsets[player.name]) do
          if type(v) == "table" and v.group == fillset.group then
            groupsize = groupsize + quickbar.get_item_count(k)
          end
        end
        for k,v in pairs(global.defaultsets) do
          if not global.personalsets[player.name][k] and v.group == fillset.group then
            groupsize = groupsize + quickbar.get_item_count(k)
          end
        end

        totalitemcount = 0
        for j=1, #array do
          if game.item_prototypes[array[j]] then
            totalitemcount = totalitemcount + maininv.get_item_count(array[j])
          end
        end
        if vehicleinv then
          for j=1, #array do
            if game.item_prototypes[array[j]] then
              totalitemcount = totalitemcount + vehicleinv.get_item_count(array[j])
            end
          end
        end
        count = math.max( 1, math.min( count, math.floor(totalitemcount / groupsize) ) )
      end

      -- Limit insertion if has limit value
      local uselimits = global.personalsets[player.name].uselimits
      if uselimits == nil then uselimits = true end
      --log("limits in autofill script" .. tostring(uselimits))
      if uselimits and fillset.limits and fillset.limits[i] then
        if count > fillset.limits[i] then
          count = fillset.limits[i]
        end
      end

      -- Determine insertable stack count if has slot count
      if fillset.slots and fillset.slots[i] then --TODO Also see if slots are full for use in hotkey filling, also check if we have a better type of ammo/fuel, ALSO check if inv full
        slots = fillset.slots[i]
      else
        slots = 1
      end

      if count < game.item_prototypes[item].stack_size * slots then
        color = YELLOW
      else
        count = game.item_prototypes[item].stack_size * slots
        color = GREEN
      end

      -- Insert, count the difference and remove the difference
      inserted = entity.get_item_count(item)
      entity.insert({name=item, count=count})
      inserted = entity.get_item_count(item) - inserted
      if inserted > 0 then
        if vehicleinv then
          removed = vehicleinv.get_item_count(item)
          vehicleinv.remove({name=item, count=inserted})
          removed = removed - vehicleinv.get_item_count(item)
          if inserted > removed then
            maininv.remove({name=item, count=inserted - removed})
          end
        else
          maininv.remove({name=item, count=inserted})
        end
        if removed then
          text({"autofill.insertion-from-vehicle", inserted, game.item_prototypes[item].localised_name, removed, game.entity_prototypes[player.vehicle.name].localised_name}, textpos, player.surface, color)
          textpos.y = textpos.y + 1
        else
          text({"autofill.insertion", inserted, game.item_prototypes[item].localised_name }, textpos, player.surface, color)
          textpos.y = textpos.y + 1
        end
      end
    end -- if not item or count < 1 then
  end -- for i=1, #fillset do
end

function getDefaultSets()
  return {
    ["car"] = {priority=order.default, global.fuels.all, global.ammo.bullets },
    ["tank"] = {priority=order.default, slots={2,1,1}, global.fuels.all, global.ammo.bullets, global.ammo.shells },
    ["diesel-locomotive"] = {priority=order.default, slots={1}, global.fuels.high},
    ["boiler"] = {priority=order.default, group="burners", limits={5}, global.fuels.high},
    ["burner-inserter"]= {priority=order.default, group="burners", limits={1}, global.fuels.high},
    ["burner-mining-drill"] = {priority=order.default, group="burners", limits={5}, global.fuels.high},
    ["stone-furnace"] = {priority=order.default, group="burners", limits={5}, global.fuels.high},
    ["steel-furnace"] = {priority=order.default, group="burners", limits={5}, global.fuels.high},
    ["gun-turret"]= {priority=order.default, group="turrets", limits= {10}, global.ammo.bullets }
  } -- if group is defined, then insertable items are divided for buildable
  -- items in quickbar (and in hand).
end

function getLiteSets()
  return {
    ["burner-inserter"]= {priority=order.default, group="burners", limits={1}, global.fuels.high},
    ["gun-turret"]= {priority=order.default, group="turrets", limits= {10}, global.ammo.bullets }
  }
end

function makePersonalLiteSets()
  local personalsets = {}
  for k, v in pairs(global.defaultsets) do
    personalsets[k] = 0
  end

  personalsets["burner-inserter"] = { priority=order.default, group="burners", limits={1}, global.item_arrays["fuels-high"] }
  personalsets["gun-turret"] = { priority=order.default, group="turrets", limits= {10}, global.item_arrays["ammo-bullets"] }

  return personalsets
end

function globalPrint(msg)
  local players = game.players
  if type(msg) == "string" then
    output= msg
  else
    output=serpent.dump(msg, {name="var", comment=false, sparse=false, sortkeys=true})
  end
  --msg = { "autofill.msg-template", msg }
  for i=1, #players do
    players[i].print(output)
  end
  printToFile(output)
end

function initMod(reset,update)
  if not global.defaultsets or not global.personalsets or not global.item_arrays or reset then
    global = {} -- Clears global

    loader.loadBackup()

    if not update or reset then
      if reset then global.personalsets = {} end
      for k, player in pairs(game.players) do
        global.personalsets[player.name] = { active = true, uselimits=true, usegroups=true}
      end
    end

    global.has_init = true
    log("Autofill: Initilized")
  else
    if update then
      loader.loadBackup()
      log("autofill: Defaults Updated")
    else
      loader.updateFuelArrays(global.item_arrays)
    end
  end
end

function isValidEntity(name)
  if game.entity_prototypes[name] then
    return true
  end

  globalPrint( {"autofill.invalid-entityname", tostring(name)} )
  return false
end

-- This fuction not just verifies the set, but also links strings into item arrays (replaces).
function isValidSet(set)
  if set == nil or set == 0 then
    return true
  elseif type(set) == "table" then
    for i = 1, #set do

      if type(set[i]) == "string" then

        if global.item_arrays[set[i]] then -- replace name with array
          set[i] = global.item_arrays[set[i]]
        else
          if game.item_prototypes[set[i]] then
            set[i] = { set[i] }
          else
            globalPrint( {"autofill.invalid-itemname", tostring(set[i])} )
            return false
          end
        end

      elseif type(set[i]) == "table" then

        for j = 1, #set[i] do
          if game.item_prototypes[set[i][j]] == nil then
            globalPrint( {"autofill.invalid-itemname", tostring(set[i][j])} )
            return false
          end
        end

      else
        globalPrint( {"autofill.invalid-form"} )
        return false
      end

    end -- for i = 1, #set do

    return true
  end
  globalPrint( {"autofill.invalid-parameter"} )
  return false
end

function isValidUser(name)
  local players = game.players
  for i=1, #players do
    if players[i].name == name then
      return players[i].name
    end
  end

  if game.player then -- for single player game
    return game.player.name
  end

  globalPrint( {"autofill.invalid-username", tostring(name)} )
  return false
end

function text(line, pos, surface, colour) --colour as optional
  if colour == nil then
    surface.create_entity({name="flying-text", position=pos, text=line})
  else
    surface.create_entity({name="flying-text", position=pos, text=line, color=colour})
  end
end

--
-- Mod interface
--

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