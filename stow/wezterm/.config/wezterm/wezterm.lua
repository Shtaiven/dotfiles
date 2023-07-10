local wezterm = require 'wezterm'
local config = {}

-- Style
config.font = wezterm.font 'FiraCode Nerd Font Mono'
config.color_scheme = 'Gruvbox Material Dark'
config.default_cursor_style = 'SteadyBar'
config.allow_square_glyphs_to_overflow_width = "Always"

config.window_padding = {
  left = '0cell',
  right = '0cell',
  top = '0cell',
  bottom = '0cell',
}

config.window_frame = {
  -- The font used in the tab bar.
  -- Roboto Bold is the default; this font is bundled
  -- with wezterm.
  -- Whatever font is selected here, it will have the
  -- main font setting appended to it to pick up any
  -- fallback fonts you may have used there.
  font = wezterm.font { family = 'Fira Sans', weight = 'Bold' },

  -- The size of the font in the tab bar.
  -- Default to 10.0 on Windows but 12.0 on other systems
  font_size = 10.0,

  -- The overall background color of the tab bar when
  -- the window is focused
  active_titlebar_bg = '#101010',

  -- The overall background color of the tab bar when
  -- the window is not focused
  inactive_titlebar_bg = '#101010',
}

config.colors = {
  tab_bar = {
    -- The color of the inactive tab bar edge/divider
    inactive_tab_edge = 'none',

    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = '#101010',

    -- The active tab is the one that has focus in the window
    active_tab = {
      -- The color of the background area for the tab
      bg_color = '#282828',
      -- The color of the text for the tab
      fg_color = '#d4be98',

      -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
      -- label shown for this tab.
      -- The default is "Normal"
      intensity = 'Bold',
    },

    -- Inactive tabs are the tabs that do not have focus
    inactive_tab = {
      bg_color = '#101010',
      fg_color = '#5a524c',
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = '#101010',
      fg_color = '#928374',
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = '#101010',
      fg_color = '#5a524c',
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over the new tab button
    new_tab_hover = {
      bg_color = '#101010',
      fg_color = '#928374',
    },
  },
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Triangle in the upper right used for terminal tabs 
--local UPPER_RIGHT_TRIANGLE = wezterm.nerdfonts.ple_upper_right_triangle

-- Triangle in the upper left used for terminal tabs
--local UPPER_LEFT_TRIANGLE = wezterm.nerdfonts.ple_upper_left_triangle

return config
