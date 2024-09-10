local wezterm = require 'wezterm'
local config = {}

-- Startup
config.check_for_updates = false

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

config.window_decorations = "RESIZE"

-- Define common colors
local INACTIVE_BG_COLOR = '#101010'
local INACTIVE_FG_COLOR = '#5a524c'
local ACTIVE_BG_COLOR = '#282828'
local ACTIVE_FG_COLOR = '#d4be98'
local HOVER_BG_COLOR = '#101010'
local HOVER_FG_COLOR = '#928374'

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
  active_titlebar_bg = ACTIVE_BG_COLOR,

  -- The overall background color of the tab bar when
  -- the window is not focused
  inactive_titlebar_bg = INACTIVE_BG_COLOR,
}

config.colors = {
  tab_bar = {
    -- The color of the inactive tab bar edge/divider
    inactive_tab_edge = 'none',

    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = INACTIVE_BG_COLOR,

    -- The active tab is the one that has focus in the window
    active_tab = {
      -- The color of the background area for the tab
      bg_color = ACTIVE_BG_COLOR,
      -- The color of the text for the tab
      fg_color = ACTIVE_FG_COLOR,

      -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
      -- label shown for this tab.
      -- The default is "Normal"
      intensity = 'Bold',
    },

    -- Inactive tabs are the tabs that do not have focus
    inactive_tab = {
      bg_color = INACTIVE_BG_COLOR,
      fg_color = INACTIVE_FG_COLOR,
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = HOVER_BG_COLOR,
      fg_color = HOVER_FG_COLOR,
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = INACTIVE_BG_COLOR,
      fg_color = INACTIVE_FG_COLOR,
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over the new tab button
    new_tab_hover = {
      bg_color = HOVER_BG_COLOR,
      fg_color = HOVER_FG_COLOR,
    },
  },
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- Triangle in the upper right used for terminal tabs 
local UPPER_RIGHT_TRIANGLE = wezterm.nerdfonts.ple_upper_right_triangle

-- Triangle in the upper left used for terminal tabs
local UPPER_LEFT_TRIANGLE = wezterm.nerdfonts.ple_upper_left_triangle

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
  local title = tab_info.tab_title
  local index = tab_info.tab_index+1
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return index .. ':' .. title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return index .. ":" .. tab_info.active_pane.title
end

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local edge_background = INACTIVE_BG_COLOR
    local background = INACTIVE_BG_COLOR
    local foreground = INACTIVE_FG_COLOR

    if tab.is_active then
      background = ACTIVE_BG_COLOR
      foreground = ACTIVE_FG_COLOR
    elseif hover then
      background = HOVER_BG_COLOR
      foreground = HOVER_FG_COLOR
    end

    local edge_foreground = background

    local title = tab_title(tab)

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    title = wezterm.truncate_right(title, max_width - 2)

    return {
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = UPPER_RIGHT_TRIANGLE },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = UPPER_LEFT_TRIANGLE },
    }
  end
)

-- Keybindings


return config
