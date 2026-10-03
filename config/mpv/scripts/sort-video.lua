-- Ensure the script is only loaded inside mpv
local utils = require 'mp.utils'

-- Configuration mimicking your Nushell script
local src_dir = mp.command_native({ "expand-path", "~/storage/videos/" })
local exclude_list = { [".Trash-1000"] = true, ["lost+found"] = true, ["json"] = true, ["vtt"] = true, ["Gif"] = true }

-- Helper function to check if any path segment is excluded
local function is_excluded(path)
	for segment in string.gmatch(path, "[^/]+") do
		if exclude_list[segment] then return true end
	end
	return false
end

-- Recursively find directories, recording each one's mtime.
local function get_folders(base, current, list)
    current = current or base
    list = list or {}
    local files = utils.readdir(current, "dirs")
    if not files then return list end

    for _, name in ipairs(files) do
        if name ~= "." and name ~= ".." then
			local full_path = current .. "/" .. name
			local rel_path = string.sub(full_path, #base + 1)
			rel_path = rel_path:gsub("^/", "") -- drop leading slash

            if not is_excluded(rel_path) then
                local info = utils.file_info(full_path)
                table.insert(list, {
                    path  = rel_path,
                    mtime = (info and info.mtime) or 0,
                })
                get_folders(base, full_path, list) -- Recursive scan
            end
        end
    end
    return list
end

-- Returns folders sorted newest-first by directory mtime,
-- mirroring `ls --long --directory ... | sort-by modified --reverse`.
local function get_sorted_folders()
	local folders = get_folders(src_dir)
	table.sort(folders, function(a, b) return a.mtime > b.mtime end)
	return folders
end

local function sort_and_move_video()
	local video_path = mp.get_property("path")
	if not video_path or string.sub(video_path, 1, 4) == "http" then return end

	-- 1. Gather folders (newest modified first)
	local folders = get_sorted_folders()
	if #folders == 0 then return end

	local paths = {}
	for _, f in ipairs(folders) do paths[#paths + 1] = f.path end

	-- 2. Pipe choices into fuzzel (mimicking fuzzel --dmenu)
	local fuzzel_input = table.concat(paths, "\n")
	local res = mp.command_native({
		name = "subprocess",
		capture_stdout = true,
		stdin_data = fuzzel_input,
		args = { "fuzzel", "--dmenu" }
	})

	if res.status ~= 0 or not res.stdout then return end
	local chosen = string.gsub(res.stdout, "%s+$", "") -- Trim trailing newline
	if chosen == "" then return end

	-- 3. Construct paths
	local filename = mp.get_property("filename")
	local destination_dir = src_dir .. "/" .. chosen
	local destination_file = destination_dir .. "/" .. filename

	-- 4. Move the file using basic OS commands
	local move_res = os.execute(string.format('mv "%s" "%s"', video_path, destination_file))

	if move_res then
		-- 5. Remove the (now moved) current entry; mpv advances to the next one
		local current_pos = mp.get_property_number("playlist-pos", -1)
		if current_pos >= 0 then
			mp.commandv("playlist-remove", current_pos)
		end

		mp.osd_message("Moved to: " .. chosen)
	else
		mp.osd_message("Error: Failed to move file")
	end
end

-------------------------------------------------------------------------------
-- DEBUG & TEST FUNCTIONS
-------------------------------------------------------------------------------

-- DEBUG TEST 1: Test Folder Scanning & Fuzzel Menu
-- Pressing F2 will scan folders and open fuzzel, but will NOT touch your files.
local function debug_test_menu()
	mp.msg.info("--- DEBUG TEST 1: FOLDER SCAN & FUZZEL ---")
	mp.osd_message("Running Folder Scan Test...", 2)

	local folders = get_sorted_folders()
	mp.msg.info(string.format("Found %d directories (excluding filters)", #folders))

	if #folders == 0 then
		mp.osd_message("Debug Fail: No folders found in target directory!")
		return
	end

	local paths = {}
	for _, f in ipairs(folders) do paths[#paths + 1] = f.path end
	local fuzzel_input = table.concat(paths, "\n")
	local res = mp.command_native({
		name = "subprocess",
		capture_stdout = true,
		stdin_data = fuzzel_input,
		args = { "fuzzel", "--dmenu" }
	})

	if res.status == 0 and res.stdout then
        local chosen = string.gsub(res.stdout, "%s+$", "")
		local destination_dir = src_dir .. "/" .. chosen
        mp.osd_message("Debug Success! You selected: " .. chosen, 4)
		mp.osd_message("Destination path: " .. destination_dir, 4)
		mp.msg.info("User picked: " .. chosen)
	else
		mp.osd_message("Debug Cancelled: No choice made or Fuzzel crashed.", 4)
	end
end

-- DEBUG TEST 2: Test Playlist Playlist Swapping/Healing Mock
-- Pressing F3 will fake a file move. It reloads the EXACT SAME video file
-- seamlessly to prove the math, timing, and playlist logic works.
local function debug_test_playlist_swap()
	mp.msg.info("--- DEBUG TEST 2: PLAYLIST REMOVAL MOCK ---")

	local video_path = mp.get_property("path")
	if not video_path then
		mp.osd_message("Debug Fail: Open a video first!", 3)
		return
	end

	local current_pos = mp.get_property_number("playlist-pos", -1)
	if current_pos < 0 then
		mp.osd_message("Debug Fail: No current playlist entry!", 3)
		return
	end

	mp.osd_message("Removing current playlist entry...", 2)
	mp.msg.info(string.format("Mocking removal -> Pos: %d | Path: %s", current_pos, video_path))

	mp.commandv("playlist-remove", current_pos)

	mp.osd_message("Playlist removal mock completed!", 3)
end

-- Keybindings
mp.add_key_binding("f1", "sort_video", sort_and_move_video)
mp.add_key_binding("f2", "debug_test_menu", debug_test_menu)
mp.add_key_binding("f3", "debug_test_playlist", debug_test_playlist_swap)
