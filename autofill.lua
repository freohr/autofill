--luacheck: globals autofill
autofill = {}
autofill.gui = require("gui")

-------------------------------------------------------------------------------
function autofill.get_items()
  local fuel_list, ammo_list = {}, {}
  for _, item in pairs(game.item_prototypes) do
    if item.fuel_value > 0 then
      fuel_list[#fuel_list + 1] = item.name
    end
    if item.ammo_type then
      if not ammo_list[item.ammo_type.category] then ammo_list[item.ammo_type.category] = {} end
      ammo_list[item.ammo_type.category][#ammo_list[item.ammo_type.category] + 1] = item.name
      -- list.ammo_list[item.ammo_type.category][#list.ammo_list[item.ammo_type.category +1] = item.name
    end
  end
  return {ammo_list = ammo_list, fuel_list = fuel_list}
end

function autofill.get_slots(entity)
  local slots = {
    fuel=0,
    ammo=0,
    ammo_categories = {}
  }
    if entity.get_fuel_inventory() --[[and entity.get_inventory(defines.inventory.fuel)]] then
      local inv = entity.get_fuel_inventory()
      if inv.can_insert(global.defaults.fuel_list[1]) then
        slots.fuel = #inv
      end
    end
    if entity.type == "car" and entity.get_inventory(defines.inventory.car_ammo) then
      --workaround until fuel inventory is fixed
      if entity.get_inventory(defines.inventory.fuel) then
        slots.fuel = #entity.get_inventory(defines.inventory.fuel)
      end

      local inv = entity.get_inventory(defines.inventory.car_ammo)
      slots.ammo = #inv
      for i=1, #inv do
        for name, ammo in pairs(global.defaults.ammo_list) do
          if inv.can_set_filter(i, ammo[1]) then
            slots.ammo_categories[i] = name
          end
        end
      end
    end
    if entity.type == "ammo-turret" and entity.get_inventory(defines.inventory.chest) then
      local inv = entity.get_inventory(defines.inventory.chest)
      slots.ammo = #inv
      for i=1, #inv do
        for name, ammo in pairs(global.defaults.ammo_list) do
          if inv.can_insert(ammo[1]) then
            slots.ammo_categories[i] = name
          end
        end
      end
    end

  if slots.fuel > 0 or slots.ammo > 0 then
    return slots
  else
    return nil
  end
end

function autofill.toggle_paused(player_index)
  local pdata=global.player_data[player_index]
  pdata.enabled = not pdata.enabled
  autofill.gui.toggle_paused(game.players[player_index], pdata.enabled)
end


function autofill.new_player_init(player)
  --pdata = global.player_data[player.index]
  autofill.gui.init(player)
end


function autofill.on_init()
  global.defaults = autofill.get_items()
  global.defaults.fillable_entities = {}
end

function autofill.on_configuration_changed()
--rebuild item/fuel tables if mods are added or removed
global.defaults = autofill.get_items()
end

function autofill.on_research_finished(event)
  if event.research.name == "automation" then
    for _, player in pairs(event.research.force.players) do
      autofill.gui.init(player, "automation")
    end
  end
end
script.on_event(defines.events.on_research_finished, function (event) autofill.on_research_finished(event) end)

function autofill.on_built_entity(event)
  if not global.defaults.fillable_entities[event.created_entity.name] then
    local slots = autofill.get_slots(event.created_entity)
    if slots then global.defaults.fillable_entities[event.created_entity.name] = slots  end
  end
end
script.on_event(defines.events.on_built_entity,function (event) autofill.on_built_entity(event) end)


return autofill
