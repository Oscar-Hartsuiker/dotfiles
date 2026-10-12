---------------------
---- KEYBINDINGS ----
---------------------
local programs = require("programs")

--hl.config({
--	input = {
--		kb_options = "caps:swapescape",
--	},
--})
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

--hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("/home/oscar/bin/theme-toggle.sh"))
-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(programs.terminal))
--hl.bind(mainMod .. " + d", hl.dsp.exec_cmd("emacsclient -c"))
hl.bind(mainMod .. " + o", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + SHIFT + return", hl.dsp.exec_cmd(programs.terminal2))

--localhl.bind(mainMod .. " + n", hl.dsp.exec_cmd("makoctl restore"))
--hl.bind(mainMod .. "+ SHIFT + n", hl.dsp.exec_cmd("makoctl dismiss -a --no-history"))
hl.bind(mainMod .. " + w", hl.dsp.exec_cmd(programs.whatsapp))

--hl.bind(mainMod .. " + COMMA", hl.dsp.exec_cmd("rofi -modi nerdy -show nerdy"))
--hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("~/.config/rofi/scripts/emoji.sh"))
-- hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. "+ SHIFT + E", hl.dsp.exec_cmd(programs.yazi))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(programs.browser2))
--hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Z", hl.dsp.window.fullscreen({ mode = "fullscreen", client = 0, action = "toggle" }))
--hl.bind(mainMod .. " + space", function()
--hl.exec_cmd("pgrep -x rofi && pkill -x rofi || " .. programs.menu)
--end)
--hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

--hl.bind(
--	"SUPER + C",
--	hl.dsp.exec_cmd(
--		"cliphist list | rofi -dmenu -theme ~/.config/rofi/catppuccin-mocha.rasi| cliphist decode | wl-copy"
--)
--)
--hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("pgrep -x rofi && pkill -x rofi || ~/.config/rofi/scripts/powermenu.sh"))

--hl.bind("SUPER + N", hl.dsp.exec_cmd("pgrep -x rofi && pkill -x rofi -t ~/.config/rofi/networkmenu.rasi"))

--hl.bind(mainMod .. " + s", hl.dsp.layout("togglesplit")) -- dwindle only

-- Use this one to bind different actions to the same key binding based on current layout:

local function layout_bind(bind_table)
	return function()
		local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()

		if not workspace then
			return
		end

		local layout = workspace.tiled_layout

		if bind_table[layout] then
			hl.dispatch(bind_table[layout])
		end
	end
end

hl.bind("SUPER + left", function()
	layout_bind({
		scrolling = hl.dsp.focus({ direction = "left" }),
		dwindle = hl.dsp.focus({ direction = "left" }),
		monocle = hl.dsp.layout("cycleprev"),
		master = hl.dsp.focus({ direction = "left" }),
	})() -- This executes your layout switch
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" })) -- This raises the window
end)

hl.bind("SUPER + h", function()
	layout_bind({
		scrolling = hl.dsp.focus({ direction = "left" }),
		dwindle = hl.dsp.focus({ direction = "left" }),
		monocle = hl.dsp.layout("cycleprev"),
		master = hl.dsp.focus({ direction = "left" }),
	})()
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind("SUPER + right", function()
	layout_bind({
		scrolling = hl.dsp.focus({ direction = "right" }),
		dwindle = hl.dsp.focus({ direction = "right" }),
		monocle = hl.dsp.layout("cyclenext"),
		master = hl.dsp.focus({ direction = "right" }),
	})()
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind("SUPER + l", function()
	layout_bind({
		scrolling = hl.dsp.focus({ direction = "right" }),
		dwindle = hl.dsp.focus({ direction = "right" }),
		monocle = hl.dsp.layout("cyclenext"),
		master = hl.dsp.focus({ direction = "right" }),
	})()
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
-- Move focus with mainMod + arrow keys
--hhl.bind(mainMod .. " + left", hl.dsp.layout("cycleprev"))
--hl.bind(mainMod .. " + right", hl.dsp.layout("cyclenext"))
--hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
--hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + i", hl.dsp.layout("swapwithmaster auto"))
-- Directional Focus Binds
hl.bind(mainMod .. " + up", function()
	hl.dispatch(hl.dsp.focus({ direction = "up" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + down", function()
	hl.dispatch(hl.dsp.focus({ direction = "down" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + k", function()
	hl.dispatch(hl.dsp.focus({ direction = "up" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + j", function()
	hl.dispatch(hl.dsp.focus({ direction = "down" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Vim-style Window Swapping Binds
hl.bind(mainMod .. "+ SHIFT + h", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "left" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. "+ SHIFT + l", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "right" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + SHIFT + k", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "up" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + SHIFT + j", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "down" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + bracketright", hl.dsp.group.next())
hl.bind(mainMod .. " + bracketleft", hl.dsp.group.prev())

-- Move active window to a workspace with mainMod + SHIFT + F1-F10
for i = 1, 8 do
	-- If i is 10, i % 10 equals 0, mapping F10 to "F0"
	local remainder = i % 10
	local fnKey = "F" .. tostring(remainder)
	-- Move window to workspace (e.g., SUPER + F1 -> Workspace 1)
	hl.bind(mainMod .. " + " .. fnKey, hl.dsp.window.move({ workspace = tostring(i) }))
end
for i = 1, 8 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + m", hl.dsp.workspace.toggle_special("M"))
hl.bind(mainMod .. " + SHIFT + m", hl.dsp.window.move({ workspace = "special:M" }))

hl.bind(mainMod .. " + f", hl.dsp.workspace.toggle_special("F"))
hl.bind(mainMod .. " + SHIFT + f", hl.dsp.window.move({ workspace = "special:F" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.resize(), { mouse = true })

-- Laptop-friendly resize: hold SUPER + ALT and left-click-drag instead of
-- needing a right-click drag on the trackpad
hl.bind(mainMod .. " + ALT_L ", hl.dsp.window.resize(), { mouse = true })

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

-- Toggle current window into/out of a group (this is the core "make it a tab" action)
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())

--hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("~/.config/hypr/scripts/group-picker.sh"))
-- Cycle through windows in the group (like next/prev tab)

-- Lock the group so new windows don't auto-join it
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.lock())

-- Focus Up (Move focus up, or roll over to previous workspace if at the top edge)
hl.bind(mainMod .. " + 0", function()
	hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
end)

-- Correctly format modifiers first, then the keysym, and dispatch via a callback function
hl.bind(mainMod .. " + SHIFT + O", function()
	hl.dispatch(hl.dsp.window.move({ workspace = "e+1" }))
end)

-- Focus Down (Move focus down, or roll over to next workspace if at the bottom edge)
hl.bind(mainMod .. " + 9", function()
	hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
end)

-- Correctly format modifiers first, then the keysym, and dispatch via a callback function
hl.bind(mainMod .. " + SHIFT + 9", function()
	hl.dispatch(hl.dsp.window.move({ workspace = "e-1" }))
end)
-- Move the focused window into a group in a direction (merges into existing group)
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.move({ out_of_group = "l" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ out_of_group = "r" }))
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.move({ out_of_group = "u" }))
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.move({ out_of_group = "d" }))

-- Move a window out of its group (directionless — just pop it out)
hl.bind(mainMod .. " + SHIFT + p", hl.dsp.window.move({ out_of_group = true }))

hl.bind(mainMod .. " + CTRL + Left", hl.dsp.window.move({ into_or_create_group = "l" }))
hl.bind(mainMod .. " + CTRL + Up ", hl.dsp.window.move({ into_or_create_group = "u" }))
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.window.move({ into_or_create_group = "d" }))
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.move({ into_or_create_group = "r" }))

hl.bind(mainMod .. " + SHIFT + Tab", function()
	local current = hl.get_config("group.groupbar.enabled")
	hl.config({ group = { groupbar = { enabled = not current } } })
end)

hl.bind(mainMod .. " + backslash", function()
	local layouts = { "scrolling", "dwindle", "master", "monocle" }
	local workspace = hl.get_active_workspace()
	if hl.get_active_special_workspace() then
		workspace = hl.get_active_special_workspace()
	end

	local next_layout = "master"

	if not workspace then
		return
	end

	for i = 1, #layouts do
		if layouts[i] == workspace.tiled_layout then
			local next_layout_idx = (i % #layouts) + 1
			next_layout = layouts[next_layout_idx]
			break
		end
	end

	if workspace.special then
		hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
	else
		hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
	end
	hl.exec_cmd("pkill -RTMIN+8 waybar")
end)

hl.bind(mainMod .. " + v ", function()
	local w = hl.get_active_window()
	local was_floating = w ~= nil and w.floating
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	if w ~= nil and not was_floating then
		hl.dispatch(hl.dsp.window.resize({ x = 800, y = 600, relative = false }))
	end
end)

--hl.bind("SUPER + SHIFT + A", function()
--hl.dispatch(hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
--	hl.dispatch(hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-dock.sh"))
--	hl.dispatch(hl.dsp.exec_cmd("pkill -HUP -f waybar_peek"))
--end)
--hl.bind("SUPER + A", hl.dsp.exec_cmd("pkill -HUP -f waybar_peek"))
--
--hl.bind("SUPER + y", hl.dsp.exec_cmd("pkill -SIGUSR1 hyprexpose"))
--
----hl.bind("SUPER + Q", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-dock.sh"))
