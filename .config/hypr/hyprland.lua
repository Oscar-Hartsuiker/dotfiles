-- HYPERLAND CONFIGURATION
--
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")
-----------------------
---- LOOK AND FEEL ----
-----------------------
require("flameshot")
require("hyprlook")
---------------
---- INPUT ----
---------------
require("hyprinput")
------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "auto",
	scale = "1",
})

hl.monitor({
	output = "",
	mode = "preferred",
	mirror = "eDP-1",
})
---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local programs = require("programs")
require("programs")
-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.config({
	env = {
		"GTK_THEME,Tokyonight-Purple-Dark-Compact",
		"GTK_ICON_THEME,Papirus-Dark",
	},
})
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

hl.config({
	ecosystem = {
		enforce_permissions = true,
	},
})

hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-- HyprMod managed settings

-- HyprMod managed settings
require("hyprland-gui")
