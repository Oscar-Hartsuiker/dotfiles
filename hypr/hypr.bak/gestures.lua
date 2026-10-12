------------------
---- GESTURES ----
------------------
local programs = require("programs")
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- 3-finger horizontal swipe = switch workspaces (built-in default behavior)
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
hl.gesture({
	fingers = 4,
	direction = "up",
	action = "special",
	workspace_name = "M",
	disable_inhibit = true,
})
hl.gesture({
	fingers = 3,
	mods = "SUPER",
	direction = "horizontal",
	action = "resize",
	disable_inhibit = true,
})
hl.gesture({
	fingers = 3,
	direction = "up",
	action = function()
		hl.dispatch(hl.dsp.window.float())
	end,
})
-- 4-finger swipe down = open app launcher (rofi)
hl.gesture({
	fingers = 4,
	direction = "down",
	action = function()
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen" }))
	end,
})

hl.gesture({
	fingers = 3,
	direction = "down",
	action = function()
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized" }))
	end,
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
--hl.device({
--	name = "epic-mouse-v1",
--	sensitivity = -0.5,
--})
