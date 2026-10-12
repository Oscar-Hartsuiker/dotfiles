local home = os.getenv("HOME")
local runtime = os.getenv("XDG_RUNTIME_DIR") or "/tmp"

-- flag lives in the runtime dir, so it's wiped on logout/reboot
-- and bars are always off at startup
local function bars_enabled()
	local f = io.open(runtime .. "/hyprbars-enabled", "r")
	if f then
		f:close()
		return true
	end
	return false
end

local function dms_border_colour()
	local f = io.open(home .. "/.config/hypr/dms/colors.lua", "r")
	if not f then
		return nil
	end
	local text = f:read("*a")
	f:close()
	return text:match('active_border%s*=%s*"(rgb%(%x+%))"')
end

--hl.on("hyprland.start", function()
--	hl.exec_cmd("hyprpm reload -n")
--end)

-- only runs after the toggle script has loaded the plugin
if bars_enabled() then
	local bar = dms_border_colour() or "rgb(1a1a1a)"

	hl.config({
		plugin = {
			hyprbars = {
				bar_height = 34,
				bar_color = bar,
				["col.text"] = "rgb(cccccc)",
				bar_title_enabled = false,
				bar_buttons_alignment = "right",
				bar_padding = 8,
				bar_button_padding = 8,
			},
		},
	})

	-- close button only
	hl.plugin.hyprbars.add_button({
		bg_color = "rgb(ff4040)",
		fg_color = "rgb(ffffff)",
		size = 24,
		icon = "",
		action = "hyprctl dispatch 'hl.dsp.window.close()'",
	})

	-- hide bars everywhere, then bring them back for Ardour and Reaper
	hl.window_rule({ match = { class = ".*" }, ["hyprbars:no_bar"] = true })
	hl.window_rule({ match = { class = "^(Ardour|REAPER).*", float = true }, ["hyprbars:no_bar"] = false })
	hl.window_rule({ match = { float = false }, ["hyprbars:no_bar"] = true })
	hl.window_rule({ match = { fullscreen_state_internal = 1 }, ["hyprbars:no_bar"] = true })
end

-- these don't depend on hyprbars, so they stay always-on
hl.window_rule({
	match = {
		class = "^Ardour.*",
		title = "^(Ardour - Preferences|Keyboard Shortcuts|Add Track/Bus/VCA|Audio/MIDI Setup|Plugin Selector|.*\\[.+\\])$",
		float = true,
	},
	center = true,
})

hl.window_rule({
	match = { class = "^REAPER", float = true },
	center = true,
})
