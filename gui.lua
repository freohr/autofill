--luacheck: globals autofill
Gui = Gui or require("stdlib.gui.gui")
local gui = {
  names = {
    main_button = "autofill-main-button",
    pause_button = "autofill-main-button-paused"
  }

}

local function af_main_button_click(event)
  autofill.toggle_paused(event.player_index)
end
Gui.on_click("autofill%-main%-button", af_main_button_click)

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
    pdata.pause_with_autotrash = pdata.pause_with_autotrash or false
    pdata.enabled = true

    local main_button = player.gui.top.add {
      type="button",
      name=gui.names.main_button,
      style=gui.names.main_button,
    }
    if not pdata.enabled then main_button.style = gui.names.pause_button end
  end
end



return gui
