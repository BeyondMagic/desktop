--- @since 25.5.31
local M = {
	seq = 0,
	dwell = 2.5,
}

local function record_path(path)
	Command("nu")
		:arg({
			"--no-config-file",
			"-c",
			"use ~/.config/nushell/scripts/module/dir-history.nu; dir-history record $env.YAZI_DIR_PATH",
		})
		:env("YAZI_DIR_PATH", path)
		:status()
end

local get_seq = ya.sync(function(st)
	return st.seq
end)

local prepare_current = ya.sync(function(st)
	local tab = cx.tab or cx.active
	if not tab then
		return nil
	end

	local url = tostring(tab.current.cwd)
	if url:sub(1, 1) ~= "/" then
		return nil
	end

	st.seq = st.seq + 1
	return url
end)

function M:setup(opts)
	opts = opts or {}
	if opts.dwell ~= nil then
		self.dwell = opts.dwell
	end

	local dwell = self.dwell
	ps.sub("cd", function(body)
		if not body.url then
			return
		end

		local url = tostring(body.url)
		if url:sub(1, 1) ~= "/" then
			return
		end

		self.seq = self.seq + 1
		local my_seq = self.seq

		ya.async(function()
			ya.sleep(dwell)
			if get_seq() == my_seq then
				record_path(url)
			end
		end)
	end)
end

function M:entry()
	local cwd = prepare_current()
	if cwd then
		record_path(cwd)
	end
end

return M
