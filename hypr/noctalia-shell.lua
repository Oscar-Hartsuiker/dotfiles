-- Noctalia shell integration

hl.on("hyprland.start", function()
	hl.exec_cmd("noctalia")
end)

local ipc = "noctalia msg "

-- === Panels & Overlays ===
hl.bind("SUPER + space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind("ALT + space", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind("SUPER + SHIFT + c", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center notifications"))
hl.bind("SUPER + Y", hl.dsp.exec_cmd(ipc .. "panel-toggle wallpaper"))
hl.bind("SUPER + insert", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("SUPER + Delete", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind("SUPER + Escape", hl.dsp.exec_cmd(ipc .. "theme-mode-toggle"))
--hl.bind("SUPER + TAB", hl.dsp.exec_cmd(ipc .. "wallpaper-next"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher"))
hl.bind("SUPER + A", hl.dsp.exec_cmd(ipc .. "window-switcher"))

-- === Dock ===
hl.bind("SUPER + S", hl.dsp.exec_cmd(ipc .. "dock-toggle"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(ipc .. "dock-toggle"))

-- === Security ===
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))

-- === Audio Controls ===
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up 3"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down 3"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "mic-mute"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc .. "media next"), { locked = true })

-- === Brightness Controls ===
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up 5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down 5"), { locked = true, repeating = true })

-- === Screenshots ===
hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind("ALT + Print", hl.dsp.exec_cmd(ipc .. "screenshot-annotate"))

-- === Custom ===
hl.bind("SUPER + ALT + F", hl.dsp.exec_cmd("quickshell -c forecast"))

-- === Rules ===
--hl.window_rule({ match = { class = "^(dev\\.noctalia\\.Noctalia)$" }, float = true })
--hl.layer_rule({ match = { namespace = "^(noctalia)$" }, no_anim = true })
