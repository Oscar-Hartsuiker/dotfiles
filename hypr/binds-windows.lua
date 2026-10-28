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
-- Unbind all conflicting binds (choose only the ones you want to remove)
hl.unbind("SUPER + left")
hl.unbind("SUPER + h")
hl.unbind("SUPER + right")
hl.unbind("SUPER + l")

hl.unbind("SUPER + up")
hl.unbind("SUPER + down")
hl.unbind("SUPER + k")
hl.unbind("SUPER + j")

hl.unbind("SUPER + SHIFT + h")
hl.unbind("SUPER + SHIFT + l")
hl.unbind("SUPER + SHIFT + k")
hl.unbind("SUPER + SHIFT + j")

hl.unbind("SUPER + bracketright")
hl.unbind("SUPER + bracketleft")

hl.unbind("SUPER + CTR + Left ")
hl.unbind("SUPER + CTR + Right ")
hl.unbind("SUPER + CTR + Up ")
hl.unbind("SUPER + CTR + Down ")
hl.unbind("SUPER + SHIFT + Left")
hl.unbind("SUPER + SHIFT + Right")
hl.unbind("SUPER + SHIFT + Up ")
hl.unbind("SUPER + SHIFT + Down ")
-- (and optionally "SUPER + i" if you want)

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
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.lock())
-- Move the focused window into a group in a direction (merges into existing group)
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.move({ out_of_group = "l" }))
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.move({ out_of_group = "r" }))
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.move({ out_of_group = "u" }))
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.move({ out_of_group = "d" }))

-- Move a window out of its group (directionless — just pop it out)
hl.bind(mainMod .. " + CTRL + G", hl.dsp.window.move({ out_of_group = true }))

hl.bind(mainMod .. " + CTRL + Left", hl.dsp.window.move({ into_or_create_group = "l" }))
hl.bind(mainMod .. " + CTRL + Up ", hl.dsp.window.move({ into_or_create_group = "u" }))
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.window.move({ into_or_create_group = "d" }))
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.move({ into_or_create_group = "r" }))

hl.bind(mainMod .. " + bracketright", hl.dsp.group.next())
hl.bind(mainMod .. " + bracketleft", hl.dsp.group.prev())
