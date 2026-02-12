-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
config.colors = {
	-- the first number is the hue measured in degrees with a range
	-- of 0-360.
	-- The second number is the saturation measured in percentage with
	-- a range of 0-100.
	-- The third number is the lightness measured in percentage with
	-- a range of 0-100.
	background = '040c16',
	-- Overrides the cell background color when the current cell is occupied by the
	-- cursor and the cursor style is set to Block
	cursor_bg = '000000',
	-- Overrides the text color when the current cell is occupied by the cursor
	cursor_fg = '0044c5',
}
-- config.font = wezterm.font 'Jetbrains Mono'
config.font = wezterm.font 'FantasqueSansM Nerd Font Mono'
config.font_size = 18.0
config.window_background_opacity = 0.9
config.text_background_opacity = 0.3
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"


-- Leader key is Ctrl-b (like tmux)
config.leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 1000 }

config.inactive_pane_hsb = {
	saturation = 1.0, -- more desaturated
	brightness = 0.5, -- darker
}


local act = wezterm.action

local function yabai_focus(dir)
	-- run via a login shell so PATH is correct
	wezterm.run_child_process({ "/bin/sh", "-lc", "yabai -m window --focus " .. dir })
end

local function pane_has_zellij(pane)
	local vars = pane:get_user_vars() or {}
	return vars.ZELLIJ == "1"
end

local function zellij_or_yabai(key, dir)
	return wezterm.action_callback(function(window, pane)
		if pane_has_zellij(pane) then
			-- Debug that always shows (even if notifications disabled)
			window:set_right_status("ZELLIJ")
			window:perform_action(act.SendKey { key = key, mods = "ALT" }, pane)
		else
			window:set_right_status("YABAI")
			yabai_focus(dir)
		end
	end)
end

local function yabai_warp(dir, display_dir)
	local cmd = "yabai -m window --warp " .. dir
	if display_dir then
		cmd = cmd .. " || yabai -m window --display " .. display_dir
	end
	wezterm.run_child_process({ "/bin/sh", "-lc", cmd })
end

local function zellij_or_yabai_warp(key, dir, display_dir)
	return wezterm.action_callback(function(window, pane)
		if pane_has_zellij(pane) then
			window:set_right_status("ZELLIJ")
			window:perform_action(act.SendKey { key = key, mods = "ALT|SHIFT" }, pane)
		else
			window:set_right_status("YABAI")
			yabai_warp(dir, display_dir)
		end
	end)
end

config.keys = {
	-- Movement like tmux/vim (Ctrl-b + n/e/i/o)
	{ key = "n", mods = "ALT", action = zellij_or_yabai("n", "west") },
	{ key = "e", mods = "ALT", action = zellij_or_yabai("e", "south") },
	{ key = "i", mods = "ALT", action = zellij_or_yabai("i", "north") },
	{ key = "o", mods = "ALT", action = zellij_or_yabai("o", "east") },
	{ key = "n", mods = "ALT|SHIFT", action = zellij_or_yabai_warp("N", "west", "west") },
	{ key = "e", mods = "ALT|SHIFT", action = zellij_or_yabai_warp("E", "south") },
	{ key = "i", mods = "ALT|SHIFT", action = zellij_or_yabai_warp("I", "north") },
	{ key = "o", mods = "ALT|SHIFT", action = zellij_or_yabai_warp("O", "east", "east") },
	-- Splitting Panes (Vertical = Right, Horizontal = Down)
	-- { key = 'v', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
	{
		key = 'h',
		mods = 'CTRL|SHIFT',
		action = wezterm.action_callback(function(window, pane)
			wezterm.log_info("cwd_uri is:", tostring(pane:get_current_working_dir()))
			window:perform_action(
				wezterm.action.SpawnCommandInNewWindow {
					-- cwd = pane:get_current_working_dir()
				},
				pane
			)
		end)
	},
	-- {
	-- 	key = 'c',
	-- 	mods = 'LEADER',
	-- 	action = wezterm.action.CloseCurrentPane { confirm = false },
	-- },

	-- Scrollback to Neovim (Ctrl-s + e)
	{
		key = 'e',
		mods = 'LEADER',
		action = wezterm.action_callback(function(window, pane)
			local scrollback = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
			local tmpfile = os.tmpname() .. '.log'
			local f = io.open(tmpfile, 'w+')
			if f then
				f:write(scrollback)
				f:close()
				window:perform_action(
					wezterm.action.SpawnCommandInNewWindow {
						args = { 'nvim', tmpfile },
					},
					pane
				)
			end
		end),
	},
	-- {
	-- 	key = 'e',
	-- 	mods = 'CTRL|SHIFT',
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local scrollback = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
	-- 		local tmpfile = os.tmpname() .. '.log'
	-- 		local f = io.open(tmpfile, 'w+')
	-- 		print "hello"
	-- 		f:write(scrollback)
	-- 		f:close()
	-- 		window:perform_action(
	-- 			wezterm.action.SplitPane {
	-- 				direction = 'Bottom',
	-- 				size = { Percent = 50 },
	-- 				command = { args = { 'nvim', tmpfile } },
	-- 			},
	-- 			pane
	-- 		)
	-- 	end),
	-- },
}

config.keys = config.keys or {}
table.insert(config.keys, {
	key = "Tab",
	mods = "SHIFT",
	action = wezterm.action.SendString("\x1b[Z"),
})
-- Make Option behave like Alt (don’t produce composed/special chars)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

return config
