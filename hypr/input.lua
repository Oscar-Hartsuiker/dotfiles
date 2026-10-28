-- Input configuration — https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
	input = {
		sensitivity = 1.0,
		-- accel_profile = "flat",
		accel_profile = "custom 1 0 2 4 6 8",
		scroll_factor = 2.0,
		-- empty inherits XKB_DEFAULT_LAYOUT (libxkbcommon), falls back to "us"
		kb_layout = "",
		numlock_by_default = true,
		kb_options = "caps:swapescape",
		follow_mouse = 1,
		touchpad = {
			tap_to_click = true,
			natural_scroll = true,
			disable_while_typing = true,
		},
	},
})
