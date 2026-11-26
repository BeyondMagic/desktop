--- @since 25.5.31

local get_paths = ya.sync(function()
	local urls = {}

	for _, f in pairs(cx.active.selected) do
		urls[#urls + 1] = tostring(f.url)
	end

	if #urls == 0 then
		local h = cx.active.current.hovered
		if not h then
			return urls
		end
		urls[#urls + 1] = tostring(h.url)
	end

	return urls
end)

local function notify_error(content)
	ya.notify({
		title = "copy-paths",
		content = content,
		timeout = 5,
		level = "error",
	})
end

local function entry()
	local urls = get_paths()
	if #urls == 0 then
		return
	end

	local child, spawn_err = Command("wl-copy")
		:stdin(Command.PIPED)
		:stdout(Command.NULL)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		notify_error("wl-copy failed to start: " .. tostring(spawn_err))
		return
	end

	local ok, write_err = child:write_all(table.concat(urls, "\n"))
	if not ok then
		notify_error("wl-copy write failed: " .. tostring(write_err))
		return
	end

	local out, wait_err = child:wait_with_output()
	if not out or not out.status.success then
		local detail = out and out.stderr ~= "" and out.stderr or tostring(wait_err or (out and out.status.code))
		notify_error("wl-copy failed: " .. detail)
	end
end

return { entry = entry }
