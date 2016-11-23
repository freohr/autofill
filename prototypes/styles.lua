data:extend({
  {
    type = "font",
    name = "autofill-small-font",
    from = "default",
    size = 14
  }
})

data.raw["gui-style"].default["autofill-main-button"] =
  {
    type = "button_style",
    parent = "button_style",
    width = 33,
    height = 33,
    top_padding = 6,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    font = "autofill-small-font",
    left_click_sound =
    {
      {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
      }
    },
    default_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__AutoFill__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 64
      }
    },
    hovered_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__AutoFill__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 96
      }
    },
    clicked_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__AutoFill__/graphics/gui.png",
        width = 32,
        height = 32,
        x = 96
      }
    }
  }

  data.raw["gui-style"].default["autofill-main-button-paused"] =
  {
    type = "button_style",
    parent = "button_style",
    width = 33,
    height = 33,
    top_padding = 6,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    font = "autofill-small-font",
    left_click_sound =
    {
      {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
      }
    },
    default_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__AutoFill__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 128
      }
    },
    hovered_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__AutoFill__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 160
      }
    },
    clicked_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__AutoFill__/graphics/gui.png",
        width = 32,
        height = 32,
        x = 160
      }
    }
  }