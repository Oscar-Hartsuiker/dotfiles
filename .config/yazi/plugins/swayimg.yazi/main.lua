-- swayimg.yazi/main.lua
-- Open the hovered image fullscreen in swayimg, sync yazi's cursor back on quit.
-- Modeled on NoponyAsked/sxiv.yazi (https://github.com/NoponyAsked/sxiv.yazi)

local get_hovered = ya.sync(function()
	local f = cx.active.current.hovered
	if f == nil then
		return nil
	end
	if f:mime() == nil or f:mime():find("^image/") == nil then
		return nil
	end
	return tostring(f.url)
end)

-- move yazi's cursor to match a given filename in the current directory
local hover_file = ya.sync(function(_, filename)
	local target_index = nil
	for i, f in ipairs(cx.active.current.files) do
		if tostring(f.url) == filename then
			target_index = i
			break
		end
	end
	if target_index == nil then
		return
	end
	local delta = target_index - cx.active.current.cursor
	ya.mgr_emit("arrow", { delta })
end)

return {
	entry = function()
		local hovered = get_hovered()
		if hovered == nil then
			ya.notify({ title = "swayimg", content = "Hovered file is not an image", timeout = 3, level = "warn" })
			return
		end

		-- swayimg auto-loads sibling images from the same directory when given
		-- a single file path, so we don't need to build the full file list.
		-- -m enables mark mode: marked files print to stdout on quit, one per line.
		local child, err = Command("swayimg")
			:arg({ "--fullscreen", "-m", hovered })
			:stdout(Command.PIPED)
			:spawn()

		if child == nil then
			ya.notify({ title = "swayimg", content = "Failed to start swayimg: " .. tostring(err), timeout = 5, level = "error" })
			return
		end

		local output, out_err = child:wait_with_output()
		if output == nil then
			ya.dbg("swayimg.yazi: " .. tostring(out_err))
			return
		end

		-- sync yazi's cursor to the last marked image, if any were marked
		local last = nil
		for line in output.stdout:gmatch("([^\n]+)") do
			last = line
		end
		if last ~= nil then
			hover_file(last)
		end
	end,
}
