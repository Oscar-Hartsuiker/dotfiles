-- Environment variables and session startup

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user start hyprland-session.target")
end)

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("TERMINAL", "ghostty")
hl.env("XCURSOR_SIZE", "42")
hl.env("HYPRCURSOR_SIZE", "42")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME_QT6", "qt6ct")

hl.config({
	cursor = {
		no_hardware_cursors = true,
	},
})
