-- Layout configuration — https://wiki.hypr.land/Configuring/Layouts/

-- Dwindle — https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
hl.config({
	dwindle = {
		force_split = 2,
		preserve_split = true,
		use_active_for_splits = true,
	},
})

-- Master — https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
	master = {
		new_status = "slave",
		mfact = 0.5,
		allow_small_split = true,
		special_scale_factor = 2,
	},
})

-- Scrolling — https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
