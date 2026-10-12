-- mocha.lua
hl.config({
	general = {
		col = {
			active_border = "#b4befe", -- mocha lavender (normal focused border)
			inactive_border = "#45475a", -- mocha surface1
		},
	},
	hl.window_rule({
		match = { fullscreen = true },
		border_color = "#9AA2C4",
	}),

	-- mocha.lua group block
	group = {
		["col.border_active"] = "#94e2d5", -- mocha teal
		["col.border_inactive"] = "#45475a",
		["col.border_locked_active"] = "#74c7ec", -- mocha sapphire
		["col.border_locked_inactive"] = "#45475a",
		groupbar = {
			enabled = true,
			["col.active"] = "#94e2d5",
			["col.inactive"] = "#1e1e2e",
			["col.locked_active"] = "#74c7ec",
			["col.locked_inactive"] = "#1e1e2e",
			text_color = "rgb(11111b)",
			text_color_inactive = "rgb(6c7086)",
			blur = false,
			gaps_in = 0,
			gaps_out = 0,
			font_size = 14,
			height = 1,
			text_offset = -10,
			indicator_height = 20,
		},
	},
})
