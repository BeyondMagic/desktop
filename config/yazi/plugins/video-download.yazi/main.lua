--- @since 25.5.31

local get_cwd = ya.sync(function()
	local tab = cx.active
	if not tab then
		return nil
	end
	return tostring(tab.current.cwd)
end)

local function trim(s)
	return (s or ""):match("^%s*(.-)%s*$")
end

local function notify(content, level, timeout)
	ya.notify({
		title = "video-download",
		content = content,
		timeout = timeout or 5,
		level = level or "info",
	})
end

local function read_clipboard()
	local clip = trim(ya.clipboard())
	if clip ~= "" then
		return clip
	end

	local out = Command("wl-paste"):arg("--no-newline"):output()
	if out and out.status.success then
		return trim(out.stdout)
	end

	return ""
end

local function find_error_line(text)
	for line in (text or ""):gmatch("[^\r\n]+") do
		if line:sub(1, 7) == "ERROR: " then
			return line
		end
	end
	return nil
end

local function entry()
	local cwd = get_cwd()
	if not cwd or cwd:sub(1, 1) ~= "/" then
		notify("Cannot download into non-local directory: " .. tostring(cwd), "warn")
		return
	end

	local link, link_event = ya.input({
		title = "Video URL:",
		value = read_clipboard(),
		pos = { "center", w = 60 },
	})
	if link_event ~= 1 then
		return
	end

	link = trim(type(link) == "string" and link or "")
	if link == "" then
		notify("No URL provided.", "warn")
		return
	end

	local name, name_event = ya.input({
		title = "Filename (optional, Enter for default):",
		pos = { "center", w = 50 },
	})
	if name_event ~= 1 then
		return
	end

	name = trim(type(name) == "string" and name or "")

	notify("Starting download...", "info", 3)

	local nu_script = [[
use ~/.config/nushell/scripts/video.nu
cd $env.VIDEO_DL_DIR
if ($env.VIDEO_DL_NAME? | default "" | is-not-empty) {
	video download $env.VIDEO_DL_NAME --link $env.VIDEO_DL_LINK
} else {
	video download --link $env.VIDEO_DL_LINK
}
]]

	local out, err = Command("nu")
		:arg({ "--no-config-file", "-c", nu_script })
		:cwd(cwd)
		:env("VIDEO_DL_DIR", cwd)
		:env("VIDEO_DL_LINK", link)
		:env("VIDEO_DL_NAME", name)
		:output()

	if not out then
		notify("Failed to run nu: " .. tostring(err), "error", 8)
		return
	end

	local yt_err = find_error_line(out.stdout) or find_error_line(out.stderr)
	if not out.status.success or yt_err then
		local detail = yt_err or (trim(out.stderr) ~= "" and trim(out.stderr)) or ("exit code " .. tostring(out.status.code))
		notify("Download failed: " .. detail, "error", 8)
		return
	end

	notify("Download complete.", "info", 5)
end

return { entry = entry }
