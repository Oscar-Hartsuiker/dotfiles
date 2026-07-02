-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start hyprland-session.target")
end)

hl.on("hyprland.shutdown", function()
	os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
	-- uses a blocking exec function and sleeps a bit to give things time to close
	-- you might also want to kill troublesome/crashing non-systemd background services here:
	os.execute("pkill wallpaperthing; systemctl --user stop hyprland-session.target && sleep 0.1")
end)

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--- env = QT_QPA_PLATFORMTHEME, qt6ct
--Expose environment variables to systemd
env = QT_QPA_PLATFORMTHEME, qt6ct
--Expose environment variables to systemd
env = XDG_CURRENT_DESKTOP, Hyprland
env = XDG_SESSION_TYPE, wayland
env = XDG_SESSION_DESKTOP, Hyprland

env = QT_AUTO_SCREEN_SCALE_FACTOR, 1.25

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME")
	hl.exec_cmd("dbus-update-activation-environment --systemd QT_QPA_PLATFORMTHEME")
	hl.exec_cmd("udiskie &")
	hl.exec_cmd("tuxedo-control-center")
end)

---------------------
---- MY PROGRAMS ----
---------------------

return {
	terminal = "kitty",
	fileManager = "nautilus",
	menu = "rofi -show combi window -combi-modi window,drun",
	browser = "firefox",
}
