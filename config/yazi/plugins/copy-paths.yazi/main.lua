--- @since 25.5.31
--- @sync entry

local function entry()
	local urls = {}

	for _, f in pairs(cx.active.selected) do
		urls[#urls + 1] = tostring(f.url)
	end

	if #urls == 0 then
		local h = cx.active.current.hovered
		if not h then return end
		urls[#urls + 1] = tostring(h.url)
	end

	local text = table.concat(urls, "\n")

	local tmp = "/tmp/yazi-copy-paths.txt"
	local fh = io.open(tmp, "w")
	if not fh then
		ya.notify { title = "copy-paths", content = "cannot write " .. tmp, timeout = 5 }
		return
	end
	fh:write(text)
	fh:close()

	local out = Command("sh")
		:arg("-c")
		:arg('wl-copy < "$1" && rm -f "$1"')
		:arg("sh")
		:arg(tmp)
		:output()

	if not out or out.status.code ~= 0 then
		ya.notify {
			title = "copy-paths",
			content = "wl-copy failed: " .. (out and (out.stderr.text or "no stderr") or "no output"),
			timeout = 5,
		}
	end
end

return { entry = entry }
