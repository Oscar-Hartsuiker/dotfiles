local mainMod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind("SUPER + X", hl.dsp.window.close())

-- SPECIAL WORKSPACES

hl.bind(mainMod .. " + z", hl.dsp.workspace.toggle_special("󰟠"))
hl.bind(mainMod .. " + SHIFT + z", function()
	hl.dispatch(hl.dsp.window.move({ workspace = "special:󰟠" }))
	hl.dispatch(hl.dsp.window.float({ action = "float" }))
	hl.dispatch(hl.dsp.window.resize({ x = 900, y = 600, relative = false }))
end)

--- FLOAT WINDOW
---
hl.bind(mainMod .. " + d ", function()
	local w = hl.get_active_window()
	local was_floating = w ~= nil and w.floating
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
	if w ~= nil and not was_floating then
		hl.dispatch(hl.dsp.window.resize({ x = 900, y = 600, relative = false }))
	end
end)

for workspace = 1, 10 do
	local key = "code:" .. tostring(workspace + 9)
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = workspace }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace, follow = true }))
	hl.bind("SUPER + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = workspace, follow = false }))
end
-- Move active window to a workspace with mainMod + SHIFT + F1-F10
for i = 1, 8 do
	-- If i is 10, i % 10 equals 0, mapping F10 to "F0"
	local remainder = i % 10
	local fnKey = "F" .. tostring(remainder)
	-- Move window to workspace (e.g., SUPER + F1 -> Workspace 1)
	hl.bind(mainMod .. " + " .. fnKey, hl.dsp.window.move({ workspace = tostring(i) }))
end

hl.bind("SUPER + SHIFT + M", function()
	local ws = hl.get_active_workspace()
	if ws then
		hl.workspace_rule({ workspace = ws.name, layout = "master" })
	end
end)

hl.bind("SUPER + M", function()
	local ws = hl.get_active_workspace()
	if not ws then
		return
	end
	local next_layout = (ws.tiled_layout == "monocle") and "master" or "monocle"
	hl.workspace_rule({ workspace = ws.name, layout = next_layout })
end)

-- NAVIGATION OVERRIDES
-- Use this one to bind different actions to the same key binding based on current layout:

local function layout_bind(bind_table)
	return function()
		local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()

		if not workspace then
			return
		end

		local layout = workspace.tiled_layout

		if bind_table[layout] then
			hl.dispatch(bind_table[layout])
		end
	end
end

hl.bind("SUPER + left", function()
	layout_bind({
		scrolling = hl.dsp.focus({ direction = "left" }),
		dwindle = hl.dsp.focus({ direction = "left" }),
		monocle = hl.dsp.layout("cycleprev"),
		master = hl.dsp.focus({ direction = "left" }),
	})() -- This executes your layout switch
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" })) -- This raises the window
end)

hl.bind("SUPER + h", function()
	layout_bind({
		scrolling = hl.dsp.focus({ direction = "left" }),
		dwindle = hl.dsp.focus({ direction = "left" }),
		monocle = hl.dsp.layout("cycleprev"),
		master = hl.dsp.focus({ direction = "left" }),
	})()
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind("SUPER + right", function()
	layout_bind({
		scrolling = hl.dsp.focus({ direction = "right" }),
		dwindle = hl.dsp.focus({ direction = "right" }),
		monocle = hl.dsp.layout("cyclenext"),
		master = hl.dsp.focus({ direction = "right" }),
	})()
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind("SUPER + l", function()
	layout_bind({
		scrolling = hl.dsp.focus({ direction = "right" }),
		dwindle = hl.dsp.focus({ direction = "right" }),
		monocle = hl.dsp.layout("cyclenext"),
		master = hl.dsp.focus({ direction = "right" }),
	})()
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
-- Move focus with mainMod + arrow keys
--hhl.bind(mainMod .. " + left", hl.dsp.layout("cycleprev"))
--hl.bind(mainMod .. " + right", hl.dsp.layout("cyclenext"))
--hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
--hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + u", hl.dsp.layout("swapwithmaster auto"))
-- Directional Focus Binds
hl.bind(mainMod .. " + up", function()
	hl.dispatch(hl.dsp.focus({ direction = "up" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + down", function()
	hl.dispatch(hl.dsp.focus({ direction = "down" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + k", function()
	hl.dispatch(hl.dsp.focus({ direction = "up" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + j", function()
	hl.dispatch(hl.dsp.focus({ direction = "down" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Vim-style Window Swapping Binds
hl.bind(mainMod .. "+ SHIFT + h", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "left" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. "+ SHIFT + l", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "right" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + SHIFT + k", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "up" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

hl.bind(mainMod .. " + SHIFT + j", function()
	hl.dispatch(hl.dsp.window.swap({ direction = "down" }))
	hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
---
---GROUPS
---
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
-- Move a window out of its group (directionless — just pop it out)
hl.bind(mainMod .. " + ALT  + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.lock())
-- Move the focused window into a group in a direction (merges into existing group)

hl.bind(mainMod .. " + ALT + Left", hl.dsp.window.move({ into_or_create_group = "l" }))
hl.bind(mainMod .. " + ALT + Up ", hl.dsp.window.move({ into_or_create_group = "u" }))
hl.bind(mainMod .. " + ALT + Down", hl.dsp.window.move({ into_or_create_group = "d" }))
hl.bind(mainMod .. " + ALT + Right", hl.dsp.window.move({ into_or_create_group = "r" }))

hl.bind(mainMod .. " + ALT + h", hl.dsp.window.move({ into_or_create_group = "l" }))
hl.bind(mainMod .. " + ALT + k", hl.dsp.window.move({ into_or_create_group = "u" }))
hl.bind(mainMod .. " + ALT + j", hl.dsp.window.move({ into_or_create_group = "d" }))
hl.bind(mainMod .. " + ALT + l", hl.dsp.window.move({ into_or_create_group = "r" }))

hl.bind(mainMod .. " + bracketright", hl.dsp.group.next())
hl.bind(mainMod .. " + bracketleft", hl.dsp.group.prev())

hl.bind("SUPER + ALT + TAB", hl.dsp.group.next())
hl.bind("SUPER + ALT + SHIFT + TAB", hl.dsp.group.prev())

hl.bind("SUPER + CTRL + LEFT", hl.dsp.group.prev())
hl.bind("SUPER + CTRL + RIGHT", hl.dsp.group.next())

hl.bind("SUPER + CTRL + h", hl.dsp.group.prev())
hl.bind("SUPER + CTRL + l", hl.dsp.group.next())

hl.bind("SUPER + ALT + mouse_down", hl.dsp.group.next())
hl.bind("SUPER + ALT + mouse_up", hl.dsp.group.prev())

for index = 1, 5 do
	hl.bind("SUPER + ALT + code:" .. tostring(index + 9), function()
		local w = hl.get_active_window()
		if w == nil or w.group == nil then
			return
		end
		-- if index > <group size field> then return end
		hl.dispatch(hl.dsp.group.active({ index = index }))
	end, { description = "Switch to group window " .. index })
end
-- General Hyprland keybinds (shell-independent)

-- === Application Launchers ===
hl.bind("SUPER + T", hl.dsp.exec_cmd("ghostty"))

-- === Window Management ===
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + SHIFT + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + W", hl.dsp.group.toggle())

-- === Monitor Navigation ===
hl.bind("SUPER + CTRL + left", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + CTRL + right", hl.dsp.focus({ monitor = "r" }))
hl.bind("SUPER + CTRL + H", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + CTRL + J", hl.dsp.focus({ monitor = "d" }))
hl.bind("SUPER + CTRL + K", hl.dsp.focus({ monitor = "u" }))
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ monitor = "r" }))

-- === Move to Monitor ===
hl.bind("SUPER + SHIFT + CTRL + left", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + SHIFT + CTRL + down", hl.dsp.window.move({ monitor = "d" }))
hl.bind("SUPER + SHIFT + CTRL + up", hl.dsp.window.move({ monitor = "u" }))
hl.bind("SUPER + SHIFT + CTRL + right", hl.dsp.window.move({ monitor = "r" }))
hl.bind("SUPER + SHIFT + CTRL + H", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + SHIFT + CTRL + J", hl.dsp.window.move({ monitor = "d" }))
hl.bind("SUPER + SHIFT + CTRL + K", hl.dsp.window.move({ monitor = "u" }))
hl.bind("SUPER + SHIFT + CTRL + L", hl.dsp.window.move({ monitor = "r" }))

-- === Workspace Navigation ===
hl.bind("SUPER + Period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + Comma", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + I", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("SUPER + CTRL + U", hl.dsp.window.move({ workspace = "e-1" }))

-- === Move Workspaces ===
hl.bind("SUPER + U", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + I", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + SHIFT + I", hl.dsp.window.move({ workspace = "+1" }))

-- === Mouse Wheel Navigation ===
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + mouse_down", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("SUPER + CTRL + mouse_up", hl.dsp.window.move({ workspace = "e-1" }))

-- === Sizing & Layout ===
hl.bind("SUPER + R", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("~/.local/bin/hyprcurve"))
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "set" }))

-- === Move/resize windows with mainMod + LMB/RMB and dragging ===
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

hl.bind(
	"SUPER + code:20",
	hl.dsp.window.resize({ x = -100, y = 0, relative = true }),
	{ description = "Expand window left" }
)
hl.bind(
	"SUPER + code:21",
	hl.dsp.window.resize({ x = 100, y = 0, relative = true }),
	{ description = "Shrink window left" }
)

-- === Manual Sizing ===
hl.bind("SUPER + minus", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + equal", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { repeating = true })
