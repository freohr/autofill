-------------------------------------------------------------------------------
--[[GUI]]--luacheck: globals autofill
-------------------------------------------------------------------------------
local gui = {
    names = {
        main_button = "autofill-main-button",
        pause_button = "autofill-main-button-paused",
        main_frame = "autofill-frame-main",
        header = "autofill-frame-header",
        header_player = "autofill-frame-header-player",
        header_force = "autofill-frame-header-force",
        header_global = "autofill-frame-header-global",
        header_defaults = "autofill-frame-header-defaults",
        header_settings = "autofill-frame-header-settings",
        scroll_frame = "autofill-frame-scroll",
        scroll_row = "autofill-frame-scroll-row-",
        scroll_row_col_setname = "autofill-frame-scroll-row-col-setname"
    }
}

local function create_main_frame(player)
    local main = player.gui.left.add{
        type="frame",
        name=gui.names.main_frame,
        direction = "vertical"
    }
    main.style.maximal_width = 800
    main.style.maximal_height = 400
    main.style.minimal_width = 800
    --main.style.minimal_height = 600
    local header = main.add{
        type="table",
        name=gui.names.header,
        colspan = 5
    }
    header.add{type="button", name = gui.names.header_player, caption="Player Sets"}
    header.add{type="button", name = gui.names.header_force, caption="Force Sets"}
    header.add{type="button", name = gui.names.header_global, caption="Global Sets"}
    header.add{type="button", name = gui.names.header_defaults, caption="Default Sets"}
    header.add{type="button", name = gui.names.header_settings, caption="Settings"}
    local scroll = main.add{type="scroll-pane", name = gui.names.scroll_frame, direction = "vertical"}
    scroll.style.maximal_width = 780
    scroll.style.minimal_width = 780
    scroll.style.maximal_height = 375
end

local function populate_tables(event)
    player = game.players[event.element.player_index]
    local scroll = event.element.parent.parent[gui.names.scroll_frame]
    if scroll then
        for _, child in pairs(scroll.children_names) do
            child.destroy()
        end
        if event.element.name:find("%-defaults") then
            local index = 0
            for name, set in pairs(autofill.sets.default.fill_sets) do
                index = index + 1
                local guiname = gui.names.scroll_row..index
                local row = scroll.add{type="table", name=guiname, colspan = 3}
                game.print(name)
                local col1 = row.add{type="sprite-button", name=gui.names.scroll_row_col_setname, sprite="item/"..name}
                col1.style.minimal_height=32
                col1.style.minimal_width=32
            end

        end
    end
end

Gui.on_click("autofill%-frame%-header%-", populate_tables)

local function toggle_player_pause(event)
    local player = game.players[event.player_index]
    if player.gui.top[gui.names.main_button] then
        if event.enabled then
            player.gui.top[gui.names.main_button].style = gui.names.main_button
        else
            player.gui.top[gui.names.main_button].style = gui.names.pause_button
        end
    end
end
Event.register(Event.toggle_player_paused, toggle_player_pause)

local function af_main_button_click(event)
    local player = game.players[event.player_index]
    -- autofill.players.toggle_paused(player)
    if not player.gui.left[gui.names.main_frame] then
        create_main_frame(player)
    else
        player.gui.left[gui.names.main_frame].destroy()
    end
end
Gui.on_click("autofill%-main%-button", af_main_button_click)

function gui.init(player, pdata, after_research)
    if not player.gui.top[gui.names.main_button] and (player.force.technologies["automation"].researched or after_research == "automation") then
        pdata.enabled = true
        player.gui.top.add {
            type="button",
            name=gui.names.main_button,
            style=gui.names.main_button,
        }
    end
end

return gui
