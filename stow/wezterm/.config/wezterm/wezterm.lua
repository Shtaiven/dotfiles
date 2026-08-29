local wezterm = require("wezterm")
local config = {}

-- General
config.pane_focus_follows_mouse = false
config.enable_wayland = false

-- Startup
config.check_for_updates = false

-- Persistent sessions via unix domain
config.unix_domains = { { name = "unix" } }

-- Style
config.font = wezterm.font("FiraCode Nerd Font Mono")
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.font_size = 11.0
config.underline_position = "200%"
config.color_scheme = "Gruvbox Material Dark"
config.default_cursor_style = "SteadyBar"
config.allow_square_glyphs_to_overflow_width = "Always"

config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = "0.5cell",
	bottom = "0.5cell",
}

config.enable_scroll_bar = true

-- Uncomment to remove titlebar
config.window_decorations = "TITLE|RESIZE"

-- Define common colors
local INACTIVE_BG_COLOR = "#101010"
local INACTIVE_FG_COLOR = "#5a524c"
local ACTIVE_BG_COLOR = "#202020"
local ACTIVE_FG_COLOR = "#d4be98"
local HOVER_BG_COLOR = "#101010"
local HOVER_FG_COLOR = "#928374"
local COMMAND_PALETTE_BG_COLOR = "#303030"

config.window_frame = {
	-- The font used in the tab bar.
	-- Roboto Bold is the default; this font is bundled
	-- with wezterm.
	-- Whatever font is selected here, it will have the
	-- main font setting appended to it to pick up any
	-- fallback fonts you may have used there.
	font = wezterm.font({ family = "Fira Sans", weight = "Regular" }),

	-- The size of the font in the tab bar.
	-- Default to 10.0 on Windows but 12.0 on other systems
	font_size = 11.0,

	-- The overall background color of the tab bar when
	-- the window is focused
	active_titlebar_bg = INACTIVE_BG_COLOR,

	-- The overall background color of the tab bar when
	-- the window is not focused
	inactive_titlebar_bg = INACTIVE_BG_COLOR,
}

-- Focus behavior
-- With the below set to `true`, clicking on a window will only focus wezterm
-- Behaviors like (accidentally) clicking on a link will be swallowed
config.swallow_mouse_click_on_pane_focus = true
config.swallow_mouse_click_on_window_focus = true

-- Command Palette
config.command_palette_bg_color = COMMAND_PALETTE_BG_COLOR
config.command_palette_fg_color = ACTIVE_FG_COLOR
config.command_palette_font_size = 12.0
config.command_palette_rows = 24

-- Tab bar
config.integrated_title_button_style = "Gnome"
config.integrated_title_button_color = ACTIVE_FG_COLOR
config.colors = {
	tab_bar = {
		-- The color of the inactive tab bar edge/divider
		inactive_tab_edge = "none",

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
			intensity = "Bold",
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

config.tab_max_width = 24
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false

local LEFT_CIRCLE = wezterm.nerdfonts.ple_left_half_circle_thick
local RIGHT_CIRCLE = wezterm.nerdfonts.ple_right_half_circle_thick

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
	local title = tab_info.tab_title
	local index = tab_info.tab_index + 1
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

-- Tab coloration and shape
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local bar_bg = INACTIVE_BG_COLOR
	local bg = INACTIVE_BG_COLOR
	local fg = INACTIVE_FG_COLOR

	if tab.is_active then
		bg = ACTIVE_FG_COLOR
		fg = INACTIVE_BG_COLOR
	elseif hover then
		bg = HOVER_BG_COLOR
		fg = HOVER_FG_COLOR
	end

	local title = tab_title(tab)
	-- Reserve 4 cells: left circle (1) + space (1) + space (1) + right circle (1)
	local max_title_width = max_width - 4
	-- truncate_right counts graphemes, not display cells, so wide chars
	-- (like nerd font icons) can cause the title to overflow. Shrink by
	-- one grapheme at a time until it fits.
	local limit = max_title_width
	while wezterm.column_width(title) > max_title_width and limit > 0 do
		limit = limit - 1
		title = wezterm.truncate_right(title, limit)
	end

	local padding = ""
	if tab.tab_index == 0 then
		padding = " "
	end

	return {
		{ Background = { Color = bar_bg } },
		{ Text = padding },
		{ Foreground = { Color = bg } },
		{ Text = LEFT_CIRCLE },
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
		{ Text = " " .. title .. " " },
		{ Background = { Color = bar_bg } },
		{ Foreground = { Color = bg } },
		{ Text = RIGHT_CIRCLE },
		{ Background = { Color = bar_bg } },
		{ Text = " " },
	}
end)

-- Rename the current tab. Opens an inline prompt overlay pre-filled with the
-- existing title; empty input clears it so the tab falls back to the pane title.
-- Wrapped in a callback so that initial_value is read at invocation time rather
-- than once at config load.
local rename_tab = wezterm.action_callback(function(window, pane)
	window:perform_action(
		wezterm.action.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { Color = ACTIVE_FG_COLOR } },
				{ Text = "Rename tab:" },
			}),
			initial_value = window:active_tab():get_title(),
			action = wezterm.action_callback(function(win, _, line)
				-- line is nil if the prompt was cancelled with Esc
				if line ~= nil then
					win:active_tab():set_title(line)
				end
			end),
		}),
		pane
	)
end)

-- Keybindings
config.keys = {
	-- Overrides the default ReloadConfiguration binding, which is redundant here:
	-- automatically_reload_config defaults to true, and reload is still in the
	-- command palette.
	{ key = "r", mods = "CTRL|SHIFT", action = rename_tab },
	-- Alt+Enter must reach the shell (readline/ZLE bind it to insert a newline
	-- in the command buffer), so fullscreen moves to F11.
	{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "F11", action = wezterm.action.ToggleFullScreen },
}

-- smart-splits appends to config.keys, so it must come after the table above.
-- It registers nvim-aware move (ALT|hjkl) and resize (CTRL|ALT|hjkl) bindings.
local ok, smart_splits = pcall(wezterm.plugin.require, "https://github.com/mrjones2014/smart-splits.nvim")
if ok then
	smart_splits.apply_to_config(config, {
		direction_keys = { "h", "j", "k", "l" },
		modifiers = {
			move = "ALT",
			resize = "CTRL|ALT",
		},
	})
end

-- Command palette
-- Only WezTerm's built-in commands populate the palette; anything bound to an
-- action_callback (our rename, plus every smart-splits binding) is invisible
-- there by default. Label them by "mods|key" and the handler below pulls the
-- real action objects out of config.keys, so the palette invokes exactly what
-- the key does. Bindings with no label here are skipped, and if the smart-splits
-- pcall above failed its entries simply never match.
--
-- These entries cannot display their shortcut. The palette's right-aligned key
-- column renders from ExpandedCommand.keys, which WezTerm hardcodes to an empty
-- vec for everything augment-command-palette returns. Spelling the shortcut into
-- `doc` does surface it, but only inline as "<brief>. <doc>", which looks
-- inconsistent next to the built-in entries -- so leave `doc` unset.
local PALETTE_LABELS = {
	["CTRL|SHIFT|r"] = { brief = "Rename tab", icon = "md_rename_box" },

	["ALT|h"] = { brief = "Activate pane: left", icon = "md_arrow_left_box" },
	["ALT|j"] = { brief = "Activate pane: down", icon = "md_arrow_down_box" },
	["ALT|k"] = { brief = "Activate pane: up", icon = "md_arrow_up_box" },
	["ALT|l"] = { brief = "Activate pane: right", icon = "md_arrow_right_box" },

	["CTRL|ALT|h"] = { brief = "Resize pane: left", icon = "md_arrow_expand_horizontal" },
	["CTRL|ALT|j"] = { brief = "Resize pane: down", icon = "md_arrow_expand_vertical" },
	["CTRL|ALT|k"] = { brief = "Resize pane: up", icon = "md_arrow_expand_vertical" },
	["CTRL|ALT|l"] = { brief = "Resize pane: right", icon = "md_arrow_expand_horizontal" },
}

wezterm.on("augment-command-palette", function()
	local entries = {}
	for _, assignment in ipairs(config.keys) do
		local label = PALETTE_LABELS[assignment.mods .. "|" .. assignment.key]
		if label then
			table.insert(entries, {
				brief = label.brief,
				icon = label.icon,
				action = assignment.action,
			})
		end
	end
	return entries
end)

return config
