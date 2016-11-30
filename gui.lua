--luacheck: globals autofill
Gui = Gui or require("stdlib.gui.gui")
local gui = {
  names = {
    main_button = "autofill-main-button",
    pause_button = "autofill-main-button-paused"
  }

}

local function af_main_button_click(event)
  autofill.toggle_paused({player_index=event.player_index, tick=game.tick})

end
Gui.on_click("autofill%-main%-button", af_main_button_click)

function gui.toggle_paused(player, paused)
  if player.gui.top[gui.names.main_button] then
    if not paused then
      player.gui.top[gui.names.main_button].style = gui.names.main_button
    else
      player.gui.top[gui.names.main_button].style = gui.names.pause_button
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
    if pdata.paused then main_button.style = gui.names.pause_button end
  end
end



return gui
