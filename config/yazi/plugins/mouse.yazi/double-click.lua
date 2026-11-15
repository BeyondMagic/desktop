--- Double Click opening for Yazi
local M = {
	last_url = nil,
	last_time = 0,
	delay = 300,
}

local function is_selected(url_str)
	for _, f in pairs(cx.active.selected) do
		if tostring(f.url) == url_str then
			return true
		end
	end
	return false
end

function M.setup(opts)
	if opts and opts.delay then
		M.delay = opts.delay
	end
end

function M.reset()
	M.last_url = nil
	M.last_time = 0
end

-- Checks if the click qualifies as double click and handles it if so.
-- Returns true if handled, false otherwise.
function M.handle(file)
	local now = ya.time().unix
	local url_str = tostring(file.url)
	local elapsed_ms = (now - M.last_time) * 1000

	if M.last_url == url_str and elapsed_ms <= M.delay then
		-- Double click triggered: reset state
		M.reset()

		local is_dir = (file.stat and file.stat.is_dir) or (file.cha and file.cha.is_dir)
		if is_dir then
			ya.emit("enter", {})
		else
			if is_selected(url_str) then
				ya.emit("open", { hovered = false })
			else
				ya.emit("open", {})
			end
		end
		return true
	end

	-- Record current click
	M.last_url = url_str
	M.last_time = now
	return false
end

return M
