-- gruvbox-dark.lua
hl.config({
	general = {
		col = {
			active_border = "#AA95DB", -- gruvbox bright purple (normal focused border)
			inactive_border = "#504945", -- gruvbox bg2
		},
	},
	hl.window_rule({
		match = { fullscreen = true },
		border_color = "#928374", -- gruvbox gray
	}),
	-- gruvbox-dark.lua group block
	group = {
		["col.border_active"] = "#8ec07c", -- gruvbox bright aqua
		["col.border_inactive"] = "#504945", -- gruvbox bg2
		["col.border_locked_active"] = "#83a598", -- gruvbox bright blue
		["col.border_locked_inactive"] = "#504945",
		groupbar = {
			enabled = false,
			["col.active"] = "#8ec07c",
			["col.inactive"] = "#1d2021", -- gruvbox bg0_h
			["col.locked_active"] = "#83a598",
			["col.locked_inactive"] = "#1d2021",
			text_color = "rgb(1d2021)",
			text_color_inactive = "rgb(928374)",
			blur = false,
			gaps_in = 0,
			gaps_out = 0,
			font_size = 16,
			height = 1,
			text_offset = -15,
			indicator_height = 30,
		},
	},
})
