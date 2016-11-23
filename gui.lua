--luacheck: globals autofill
local gui = {
  names = {
    main_button = "autofill-main-button",
    pause_button = "autofill-main-button-paused"
  }

}

function gui.on_gui_click(event)
  if event.element.name == gui.names.main_button then
    autofill.toggle_paused(event.player_index)
  end
end
script.on_event(defines.events.on_gui_click, function(event) gui.on_gui_click(event) end)

function gui.toggle_paused(player, enabled)
  if player.gui.top[gui.names.main_button] then
    if not enabled then
      player.gui.top[gui.names.main_button].style = gui.names.pause_button
    else
      player.gui.top[gui.names.main_button].style = gui.names.main_button
    end
  end
end

function gui.init(player, after_research)
  if not player.gui.top[gui.names.main_button]
  and player.force.technologies["automation"].researched or after_research == "automation"
  then
    local pdata = global.player_data[player.index]
    pdata.pause_with_autotrash = pdata.pause_with_autotrash or true
    pdata.enabled = pdata.enabled or true

    local main_button = player.gui.top.add {
      type="button",
      name=gui.names.main_button,
      style=gui.names.main_button,
    }
    if not pdata.enabled then main_button.style = gui.names.pause_button end
  end
end



return gui
