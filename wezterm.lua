local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"

config.font = wezterm.font("FiraMono Nerd Font", { weight = "Medium" })

config.font_size = 16

config.window_decorations = "RESIZE"

-- tmux
local act = wezterm.action
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
	{
		key = "h",
		mods = "LEADER",
		action = act.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		key = "v",
		mods = "LEADER",
		action = act.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},
}

config.window_close_confirmation = "NeverPrompt"

-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

-------- Plugins should normally be applied at the end of the file ----------
local PLUGINS = {
	tmux = {
		use = "remote",
		localhost = "file://localhost" .. os.getenv("HOME") .. "/github/wez-tmux",
		remote = "https://github.com/khsoh/wez-tmux",
		upstream = "https://github.com/sei40kr/wez-tmux",
		overrides = {},
	},
	tabline = {
		use = "localhost",
		localhost = "file://localhost" .. os.getenv("HOME") .. "/github/wez-tabline",
		remote = "https://github.com/khsoh/wez-tabline",
		upstream = "https://github.com/michaelbrusegard/tabline.wez",
		overrides = {},
	},
}

for _, cfg in pairs(PLUGINS) do
	local inuse = cfg.use and cfg.use or "remote"
	cfg.plugin = wezterm.plugin.require(cfg[inuse])
end

local function active_leader(window)
	local SOLID_LEFT_ARROW = ""
	local prefix = ""
	local mode = "normal_mode"
	if window.get_active_table then
		mode = window:get_active_table()
	end
	local xcolors = PLUGINS.tabline.plugin.get_colors()[mode]

	if window:leader_is_active() then
		prefix = " " .. utf8.char(0x1f30a) -- ocean wave
		SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
	end

	local mytext = wezterm.format({
		{ Background = { Color = xcolors.a.bg } },
		{ Text = prefix },
	})
	mytext = mytext
		.. wezterm.format({
			{ Background = { Color = xcolors.a.fg } },
			{ Foreground = { Color = xcolors.a.bg } },
			{ Text = SOLID_LEFT_ARROW },
		})
	return mytext
end

-- tabline setup - the defaults are commented out
PLUGINS.tabline.plugin.setup({
	options = {
		-- icons_enabled = true,
		-- theme = 'Catppuccin Mocha',
		-- color_overrides = {},
		-- section_separators = {
		--   left = wezterm.nerdfonts.pl_left_hard_divider,
		--   right = wezterm.nerdfonts.pl_right_hard_divider,
		-- },
		-- component_separators = {
		--   left = wezterm.nerdfonts.pl_left_soft_divider,
		--   right = wezterm.nerdfonts.pl_right_soft_divider,
		-- },
		-- tab_separators = {
		--   left = wezterm.nerdfonts.pl_left_hard_divider,
		--   right = wezterm.nerdfonts.pl_right_hard_divider,
		-- },
		section_separators = {
			left = "",
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		-- tabline_a = { 'mode' },
		-- tabline_b = { 'workspace' },
		-- tabline_c = { ' ' },
		tabline_a = { active_leader },
		tabline_b = { "mode" },
		tabline_c = { "workspace" },
		-- tab_active = {
		--   'index',
		--   { 'parent', padding = 0 },
		--   '/',
		--   { 'cwd', padding = { left = 0, right = 1 } },
		--   { 'zoomed', padding = 0 },
		-- },
		-- tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
		-- tabline_x = { 'ram', 'cpu' },
		-- tabline_y = { 'datetime', 'battery' },
		tabline_y = {},
		-- tabline_z = { 'hostname' },
	},
	extensions = {},
})

for _, cfg in pairs(PLUGINS) do
	cfg.plugin.apply_to_config(config, cfg.overrides)
end

return config
