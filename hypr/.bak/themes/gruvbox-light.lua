-- gruvbox-light.lua
hl.config({
	general = {
		col = {
			active_border = "#fe8019", -- gruvbox light purple (normal focused border)
			inactive_border = "#665c54", -- gruvbox light bg2
		},
	},
	hl.window_rule({
		match = { fullscreen = true },
		border_color = "#928374", -- gruvbox gray
	}),
	-- gruvbox-light.lua group block
	group = {
		["col.border_active"] = "#427b58", -- gruvbox light aqua
		["col.border_inactive"] = "#d5c4a1", -- gruvbox light bg2
		["col.border_locked_active"] = "#076678", -- gruvbox light blue
		["col.border_locked_inactive"] = "#d5c4a1",
		groupbar = {
			enabled = false,
			["col.active"] = "#427b58",
			["col.inactive"] = "#f9f5d7", -- gruvbox light bg0_h
			["col.locked_active"] = "#076678",
			["col.locked_inactive"] = "#f9f5d7",
			text_color = "rgb(f9f5d7)",
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
