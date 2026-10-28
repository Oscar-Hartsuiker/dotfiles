hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpm reload; hyprctl reload")
end)

if hl.plugin.hyprexpo ~= nil then
	hl.config({
		plugin = {
			hyprexpo = {
				columns = 3,
				max_workspace = 9,
				gaps_in = 5,
				gaps_out = 0,
				bg_col = "rgb(111111)",
				workspace_method = "center current",
				cancel_key = "escape",
			},
		},
	})

	hl.bind("SUPER + TAB", function()
		hl.plugin.hyprexpo.expo("toggle")
	end)
end
