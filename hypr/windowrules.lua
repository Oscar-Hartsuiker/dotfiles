-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.

-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

hl.window_rule({
	match = { group = true },
	rounding = 0,
})
hl.window_rule({
	name = "no-gaps-f1",
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})
hl.workspace_rule({
	workspace = "f[1]", -- or whatever selector matches fullscreen/single-window workspaces
	gaps_out = 0,
	gaps_in = 0,
})
-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true, -- You probably want this
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
	master = {
		new_status = "slave",
		mfact = 0.5,
		allow_small_split = true,
		special_scale_factor = 2,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})

----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = 1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
	},
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
--hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
--hl.workspace_rule({ workspace = "special:󰟠", gaps_out = 0, gaps_in = 0 })
hl.window_rule({
	match = { workspace = "special:󰟠" },
	float = true,
	size = { 1000, 700 },
	rounding = 8,
})
--hl.workspace_rule({ workspace = "4", layout = "scrolling" })
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
	match = { workspace = "special:M" },
	opacity = 0.75,
})
-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(true)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = true,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	match = { fullscreen = true },
	border_color = "#9AA2C4",
	border_size = 0,
})

--hl.window_rule({ match = { workspace = "5" }, float = true, center = true })

-- Auto-raise floating windows instantly when focused
--[[ hl.on("window.active", function(window_object)
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end) ]]
--

-- Forward cycling: Cycles next, brings to top, stays on current workspace
hl.bind("ALT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next({ params = "noworkspace" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Backward cycling: Hold Shift to cycle in reverse
hl.bind("ALT + SHIFT + Tab", function()
	hl.dispatch(hl.dsp.window.cycle_next({ params = "prev noworkspace" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.window_rule({
	name = "guitarix",
	match = { class = "guitarix" },
	float = true,
})

hl.window_rule({
	name = "QjackCtl",
	match = { class = "QjackCtl" },
	float = true,
})

hl.window_rule({
	name = "qjackctl",
	match = { class = "org.rncbc.qjackctl" },
	float = true,
})

hl.window_rule({
	name = "Pavcontrol",
	match = { class = "org.pulseaudio.pavucontrol" },
	float = true,
})

hl.window_rule({
	name = "blueman-manager",
	match = { class = "blueman-manager" },
	float = true,
})

hl.window_rule({
	name = "tuxedo",
	match = { class = "tuxedo-control-center" },
	fullscreen = true,
})

hl.window_rule({
	name = "zapzap",
	match = { class = "com.rtosta.zapzap" },
	float = true,
})

hl.window_rule({
	name = "nwg-look",
	match = { class = "nwg-look" },
	float = true,
})

hl.window_rule({
	name = "qtct",
	match = { class = "qt6ct" },
	float = true,
})
hl.window_rule({
	name = "qtct",
	match = { class = "qt5ct" },
	float = true,
})

hl.window_rule({
	name = "calc",
	match = { class = "org.gnome.Calculator" },
	float = true,
})

hl.window_rule({
	name = "drawer",
	match = { class = "nwg-drawer" },
	float = true,
	size = "600 600",
})
