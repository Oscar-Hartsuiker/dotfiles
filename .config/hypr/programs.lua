-------------------
---- AUTOSTART ----
-------------------
--user stop hyprland-session.target && sleep 0.1")
-- uses a blocking exec function and sleeps a bit to give things time to close
-- you might also want to kill troublesome/crashing non-systemd background services here:

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--- env = QT_QPA_PLATFORMTHEME, qt6ct
--Expose environment variables to systemd
env = QT_QPA_PLATFORMTHEME, qt6ct
--Expose environment variables to systemd

env = QT_AUTO_SCREEN_SCALE_FACTOR, 1.25

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- blueman-applet")
	hl.exec_cmd("uwsm app -- udiskie --smart-tray --notify")
	hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
	hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
end)

---------------------
---- MY PROGRAMS ----
---------------------

return {
	terminal = "kitty",
	fileManager = "nautilus",
	menu = "rofi -show combi -combi-modi window,drun",
	browser = "firefox",
}
