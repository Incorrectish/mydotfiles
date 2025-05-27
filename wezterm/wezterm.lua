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


-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- config.tab_bar_style = {
--   active_tab_left = wezterm.format {
--     { Background = { Color = '#0b0022' } },
--     { Foreground = { Color = '#2b2042' } },
--     { Text = SOLID_LEFT_ARROW },
--   },
--   active_tab_right = wezterm.format {
--     { Background = { Color = '#0b0022' } },
--     { Foreground = { Color = '#2b2042' } },
--     { Text = SOLID_RIGHT_ARROW },
--   },
--   inactive_tab_left = wezterm.format {
--     { Background = { Color = '#0b0022' } },
--     { Foreground = { Color = '#1b1032' } },
--     { Text = SOLID_LEFT_ARROW },
--   },
--   inactive_tab_right = wezterm.format {
--     { Background = { Color = '#0b0022' } },
--     { Foreground = { Color = '#1b1032' } },
--     { Text = SOLID_RIGHT_ARROW },
--   },
-- }

-- local colors = {
-- 	-- latte = {
-- 	-- 	rosewater = "#dc8a78",
-- 	-- 	flamingo = "#dd7878",
-- 	-- 	pink = "#ea76cb",
-- 	-- 	mauve = "#8839ef",
-- 	-- 	red = "#d20f39",
-- 	-- 	maroon = "#e64553",
-- 	-- 	peach = "#fe640b",
-- 	-- 	yellow = "#df8e1d",
-- 	-- 	green = "#40a02b",
-- 	-- 	teal = "#179299",
-- 	-- 	sky = "#04a5e5",
-- 	-- 	sapphire = "#209fb5",
-- 	-- 	blue = "#1e66f5",
-- 	-- 	lavender = "#7287fd",
-- 	-- 	text = "#4c4f69",
-- 	-- 	subtext1 = "#5c5f77",
-- 	-- 	subtext0 = "#6c6f85",
-- 	-- 	overlay2 = "#7c7f93",
-- 	-- 	overlay1 = "#8c8fa1",
-- 	-- 	overlay0 = "#9ca0b0",
-- 	-- 	surface2 = "#acb0be",
-- 	-- 	surface1 = "#bcc0cc",
-- 	-- 	surface0 = "#ccd0da",
-- 	-- 	crust = "#dce0e8",
-- 	-- 	mantle = "#e6e9ef",
-- 	-- 	base = "#eff1f5",
-- 	-- },
-- }


-- function M.select(palette, flavor, accent)
-- 	local c = palette[flavor]
-- 	-- shorthand to check for the Latte flavor
-- 	local isLatte = palette == "latte"

-- 	return {
-- 		foreground = c.text,
-- 		background = c.base,

-- 		cursor_fg = isLatte and c.base or c.crust,
-- 		cursor_bg = c.rosewater,
-- 		cursor_border = c.rosewater,

-- 		selection_fg = c.text,
-- 		selection_bg = c.surface2,

-- 		scrollbar_thumb = c.surface2,

-- 		split = c.overlay0,

-- 		ansi = {
-- 			isLatte and c.subtext1 or c.surface1,
-- 			c.red,
-- 			c.green,
-- 			c.yellow,
-- 			c.blue,
-- 			c.pink,
-- 			c.teal,
-- 			isLatte and c.surface2 or c.subtext1,
-- 		},

-- 		brights = {
-- 			isLatte and c.subtext0 or c.surface2,
-- 			c.red,
-- 			c.green,
-- 			c.yellow,
-- 			c.blue,
-- 			c.pink,
-- 			c.teal,
-- 			isLatte and c.surface1 or c.subtext0,
-- 		},

-- 		indexed = { [16] = c.peach, [17] = c.rosewater },

-- 		-- nightbuild only
-- 		compose_cursor = c.flamingo,

-- 		tab_bar = {
-- 			background = c.crust,
-- 			active_tab = {
-- 				bg_color = c[accent],
-- 				fg_color = c.crust,
-- 			},
-- 			inactive_tab = {
-- 				bg_color = c.mantle,
-- 				fg_color = c.text,
-- 			},
-- 			inactive_tab_hover = {
-- 				bg_color = c.base,
-- 				fg_color = c.text,
-- 			},
-- 			new_tab = {
-- 				bg_color = c.surface0,
-- 				fg_color = c.text,
-- 			},
-- 			new_tab_hover = {
-- 				bg_color = c.surface1,
-- 				fg_color = c.text,
-- 			},
-- 			-- fancy tab bar
-- 			inactive_tab_edge = c.surface0,
-- 		},

-- 		visual_bell = c.surface0,
-- 	}
-- end

-- local function select_for_appearance(appearance, options)
-- 	if appearance:find("Dark") then
-- 		return options.dark
-- 	else
-- 		return options.light
-- 	end
-- end

-- local function tableMerge(t1, t2)
-- 	for k, v in pairs(t2) do
-- 		if type(v) == "table" then
-- 			if type(t1[k] or false) == "table" then
-- 				tableMerge(t1[k] or {}, t2[k] or {})
-- 			else
-- 				t1[k] = v
-- 			end
-- 		else
-- 			t1[k] = v
-- 		end
-- 	end
-- 	return t1
-- end

-- function M.apply_to_config(c, opts)
-- 	if not opts then
-- 		opts = {}
-- 	end

-- 	-- default options
-- 	local defaults = {
-- 		flavor = "mocha",
-- 		accent = "mauve",
-- 		sync = false,
-- 		sync_flavors = { light = "latte", dark = "mocha" },
-- 		color_overrides = { mocha = {}, macchiato = {}, frappe = {}, latte = {} },
-- 		token_overrides = { mocha = {}, macchiato = {}, frappe = {}, latte = {} },
-- 	}

-- 	local o = tableMerge(defaults, opts)

-- 	-- insert all flavors
-- 	local color_schemes = {}
-- 	local palette = tableMerge(colors, o.color_overrides)
-- 	for flavor, name in pairs(mappings) do
-- 		local spec = M.select(palette, flavor, o.accent)
--     local overrides = o.token_overrides[flavor]
-- 		color_schemes[name] = tableMerge(spec, overrides)
-- 	end
-- 	if c.color_schemes == nil then
-- 		c.color_schemes = {}
-- 	end
-- 	c.color_schemes = tableMerge(c.color_schemes, color_schemes)

-- 	if opts.sync then
-- 		c.color_scheme = select_for_appearance(wezterm.gui.get_appearance(), {
-- 			dark = mappings[o.sync_flavors.dark],
-- 			light = mappings[o.sync_flavors.light],
-- 		})
-- 		c.command_palette_bg_color = select_for_appearance(wezterm.gui.get_appearance(), {
-- 			dark = colors[o.sync_flavors.dark].crust,
-- 			light = colors[o.sync_flavors.light].crust,
-- 		})
-- 		c.command_palette_fg_color = select_for_appearance(wezterm.gui.get_appearance(), {
-- 			dark = colors[o.sync_flavors.dark].text,
-- 			light = colors[o.sync_flavors.light].text,
-- 		})
-- 	else
-- 		c.color_scheme = mappings[o.flavor]
-- 		c.command_palette_bg_color = colors[o.flavor].crust
-- 		c.command_palette_fg_color = colors[o.flavor].text
-- 	end

-- 	local window_frame = {
-- 		active_titlebar_bg = colors[o.flavor].crust,
-- 		active_titlebar_fg = colors[o.flavor].text,
-- 		inactive_titlebar_bg = colors[o.flavor].crust,
-- 		inactive_titlebar_fg = colors[o.flavor].text,
-- 		button_fg = colors[o.flavor].text,
-- 		button_bg = colors[o.flavor].base,
-- 	}

-- 	if c.window_frame == nil then
-- 		c.window_frame = {}
-- 	end
-- 	c.window_frame = tableMerge(c.window_frame, window_frame)
-- end

-- return M
-- and finally, return the configuration to wezterm
return config

