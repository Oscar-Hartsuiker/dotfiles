require("general")
require("outputs")
require("general-binds")
require("noctalia").apply_theme()
require("noctalia-shell")
require("windowrules")
require("window-binds")
require("gestures")
require("binds-clipboard")
require("titlebars")
--require("hyprexpo")
hl.config({
	group = {
		groupbar = {
			enabled = true,
			blur = false,
			gaps_in = 0,
			gaps_out = 0,
			font_size = 0,
			height = 1,
			text_offset = -10,
			indicator_height = 10,
		},
	},
})
