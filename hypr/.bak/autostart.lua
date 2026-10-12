-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--Expose environment variables to systemd
env = QT_QPA_PLATFORMTHEME, qt6ct
env = QT_AUTO_SCREEN_SCALE_FACTOR, 1.25

hl.on("hyprland.start", function()
	--	hl.exec_cmd("uwsm app -- blueman-applet")
	--env	hl.exec_cmd("uwsm app -- tuxedo-control-center --tray")
	--	hl.exec_cmd("uwsm app -- udiskie --smart-tray --notify")
	hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
	hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
	--hl.exec_cmd("uwsm app -- hypridle &")
	--	hl.exec_cmd("uwsm app -- nwg-dock-hyprland -x -i 30 -mb 8 -c 'nwg-drawer --opacity 88'")
	--hl.exec_cmd("uwsm app -- nwg-drawer -r -is 64 -mt 200 -mb 200 -ml 300 -mr 300")
end)
