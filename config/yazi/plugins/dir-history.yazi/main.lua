--- @since 25.5.31

--- @class Permit
--- @field drop fun(self: self)

local M = {
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

local function pick_from_history()
	local permit = ui.hide()
	local child, spawn_err = Command("nu")
		:arg({
			"--no-config-file",
			"-c",
			[[use ~/.config/nushell/scripts/module/dir-history.nu; let p = try { dir-history pick --by-frecency } catch { "" }; if ($p | is-not-empty) { print $p }]],
		})
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		permit:drop()
		ya.notify({
			title = "dir-history",
			content = "Failed to start directory history picker: " .. tostring(spawn_err),
			timeout = 5,
			level = "error",
		})
		return
	end

	local out, wait_err = child:wait_with_output()
	permit:drop()

	if not out then
		ya.notify({
			title = "dir-history",
			content = "Directory history picker failed: " .. tostring(wait_err),
			timeout = 5,
			level = "error",
		})
		return
	end

	if not out.status.success then
		ya.notify({
			title = "dir-history",
			content = "Directory history picker exited with status " .. tostring(out.status.code),
			timeout = 5,
			level = "error",
		})
		return
	end

	local target = (out.stdout or ""):gsub("[\r\n]+$", "")
	if target ~= "" then
		ya.emit("cd", { target })
	end
end

local bump_seq = ya.sync(function(st)
	st.seq = (st.seq or 0) + 1
	return st.seq
end)

local get_seq = ya.sync(function(st)
	return st.seq or 0
end)

local prepare_current = ya.sync(function(st)
	local tab = cx.active
	if not tab then
		return nil
	end

	local url = tostring(tab.current.cwd)
	if url:sub(1, 1) ~= "/" then
		return nil
	end

	st.seq = (st.seq or 0) + 1
	return url
end)

function M:setup(opts)
	opts = opts or {}
	if opts.dwell ~= nil then
		self.dwell = opts.dwell
	end

	local dwell = self.dwell
	ps.sub("cd", function(body)
		if type(body) ~= "table" or not body.url then
			return
		end

		local url = tostring(body.url)
		if url:sub(1, 1) ~= "/" then
			return
		end

		local my_seq = bump_seq()

		ya.async(function()
			ya.sleep(dwell)
			if get_seq() == my_seq then
				record_path(url)
			end
		end)
	end)
end

function M:entry(job)
	if job and job.args and job.args[1] == "pick" then
		pick_from_history()
		return
	end

	local cwd = prepare_current()
	if cwd then
		record_path(cwd)
	end
end

return M
