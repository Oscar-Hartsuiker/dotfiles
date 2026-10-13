hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpm reload")
end)

if hl.plugin.hyprexpo ~= nil then
	hl.config({
		plugin = {
			hyprexpo = {
				columns = 3,
				gap_size = 5,
				bg_col = "rgb(111111)",
				workspace_method = "center current",
				cancel_key = "escape",
			},
		},
	})

	hl.bind("SUPER + /", function()
		hl.plugin.hyprexpo.expo("toggle")
	end)
end
