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
	direction = "down",
	action = "special",
	workspace_name = "magic",
	disable_inhibit = true,
})
hl.gesture({
	fingers = 4,
	direction = "up",
	action = function()
		hl.dispatch(hl.dsp.window.close())
	end,
})
-- 4-finger swipe down = open app launcher (rofi)
hl.gesture({
	fingers = 3,
	direction = "up",
	action = function()
		hl.exec_cmd("pgrep -x rofi && pkill -x rofi || " .. programs.menu)
	end,
})

-- 3-finger swipe down = toggle fullscreen ("maximize") on the active window
-- NOTE: if hl.dsp.window.fullscreen({}) errors on your build, try
--       hl.dsp.window.fullscreen({ action = "toggle" }) instead — check
--       the exact signature with the hyprctl Lua REPL (`hyprctl` -> repl mode).
hl.gesture({
	fingers = 3,
	direction = "down",
	action = function()
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen" }))
	end,
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})
