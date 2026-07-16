require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

require("bunny"):setup({
	hops = {
		{ key = "/", path = "/" },
		{ key = "t", path = "/tmp" },
		{ key = "~", path = "~", desc = "Home" },
		{ key = "M", path = "/mnt/space/music", desc = "Music" },
		{ key = "P", path = "/mnt/space/pictures/", desc = "Pictures" },
		{ key = "S", path = "/mnt/space", desc = "Space" },
		{ key = { "s", "c" }, path = "~/.config", desc = "Config" },
		{ key = { "s", "h" }, path = "~/.config/hypr", desc = "Config hypr" },
		{ key = { "s", "w" }, path = "~/.config/waybar", desc = "Config waybar" },
		{ key = { "s", "r" }, path = "~/.config/rofi", desc = "Config rofi" },
		{ key = { "s", "k" }, path = "~/.config/kitty", desc = "Config kitty" },
		{ key = { "s", "y" }, path = "~/.config/yazi", desc = "Config yazi" },
		{ key = { "l", "s" }, path = "~/.local/share", desc = "Local share" },
		{ key = { "l", "b" }, path = "~/.local/bin", desc = "Local bin" },
		{ key = { "l", "t" }, path = "~/.local/state", desc = "Local state" },
		-- key and path attributes are required, desc is optional
	},
	desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
	ephemeral = true, -- Enable ephemeral hops, default is true
	tabs = true, -- Enable tab hops, default is true
	notify = false, -- Notify after hopping, default is false
	fuzzy_cmd = "fzf", -- Fuzzy searching command, default is "fzf"
})
