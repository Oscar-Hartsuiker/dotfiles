-- latte.lua
hl.config({
	general = {
		col = {
			active_border = "#7287fd", -- latte lavender (normal focused border)
			inactive_border = "#bcc0cc", -- latte surface1
		},
	},
	-- latte.lua group block
	group = {
		["col.border_active"] = "#179299", -- latte teal
		["col.border_inactive"] = "#bcc0cc",
		["col.border_locked_active"] = "#04a5e5", -- latte sky
		["col.border_locked_inactive"] = "#bcc0cc",
		groupbar = {
			enabled = true,
			["col.active"] = "#179299",
			["col.inactive"] = "#e6e9ef",
			["col.locked_active"] = "#04a5e5",
			["col.locked_inactive"] = "#e6e9ef",
			text_color = "rgb(eff1f5)",
			text_color_inactive = "rgb(9ca0b0)",
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
