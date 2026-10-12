---------------
---- INPUT ----
---------------

hl.config({
	cursor = {
		hide_on_key_press = true,
	},
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0.90, -- -1.0 - 1.0, 0 means no modification.
		accel_profile = "flat",

		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
		},
	},
})
