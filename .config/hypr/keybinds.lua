---------------------
---- KEYBINDINGS ----
---------------------
local programs = require("programs")

hl.config({
	input = {
		kb_options = "caps:swapescape",
	},
})
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("/home/oscar/bin/theme-toggle.sh"))
-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(programs.terminal))
local closeWindowBind = hl.bind(mainMod .. " + x", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)

hl.bind(mainMod .. " + COMMA", hl.dsp.exec_cmd("rofi -modi nerdy -show nerdy"))
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("~/.config/rofi/scripts/emoji.sh"))
-- hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. "+ SHIFT + E", hl.dsp.exec_cmd(programs.yazi))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Z", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + space", function()
	hl.exec_cmd("pgrep -x rofi && pkill -x rofi || " .. programs.menu)
end)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

hl.bind(
	"SUPER + C",
	hl.dsp.exec_cmd(
		"cliphist list | rofi -dmenu -theme ~/.config/rofi/catppuccin-mocha.rasi| cliphist decode | wl-copy"
	)
)
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("pgrep -x rofi && pkill -x rofi || ~/.config/rofi/scripts/powermenu.sh"))

hl.bind("SUPER + N", hl.dsp.exec_cmd("pgrep -x rofi && pkill -x rofi -t ~/.config/rofi/networkmenu.rasi"))

hl.bind(mainMod .. " + s", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows with mainMod + hjkl (vim-style)
hl.bind(mainMod .. " + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.window.swap({ direction = "down" }))

-- Move active window to a workspace with mainMod + SHIFT + F1-F10
for i = 1, 9 do
	-- If i is 10, i % 10 equals 0, mapping F10 to "F0"
	local remainder = i % 10
	local fnKey = "F" .. tostring(remainder)
	-- Move window to workspace (e.g., SUPER + F1 -> Workspace 1)
	hl.bind(mainMod .. " + " .. fnKey, hl.dsp.window.move({ workspace = tostring(i) }))
end
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + m", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + m", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Laptop-friendly resize: hold SUPER + ALT and left-click-drag instead of
-- needing a right-click drag on the trackpad
hl.bind(mainMod .. " + ALT_L ", hl.dsp.window.resize(), { mouse = true })

-- Resize with keys

-- Switch to a submap called `resize`.
hl.bind(mainMod .. " + SHIFT + return", hl.dsp.submap("resize"))

-- Start a submap called "resize".
hl.define_submap("resize", function()
	-- Set repeating binds for resizing the active window.
	hl.bind("right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
	hl.bind("left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
	-- vim binds
	hl.bind("l", hl.dsp.window.resize({ x = 8, y = 0, relative = true }), { repeating = true })
	hl.bind("h", hl.dsp.window.resize({ x = -8, y = 0, relative = true }), { repeating = true })
	hl.bind("k", hl.dsp.window.resize({ x = 0, y = 8, relative = true }), { repeating = true })
	hl.bind("j", hl.dsp.window.resize({ x = 0, y = -8, relative = true }), { repeating = true })
	-- Use `reset` to go back to the global submap
	hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Keybinds further down will be global again...
-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
