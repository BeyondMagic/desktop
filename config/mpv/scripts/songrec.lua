-- João Farias © BeyondMagic <beyondmagic@mail.ru> 2026
--
-- SongRec audio recognition for mpv.
-- Extracts a short audio snippet around the current playback position,
-- recognizes it via `songrec`, downloads the cover art, and displays an
-- interactive desktop notification with a "Search on YouTube" button.

local utils = require("mp.utils")

local SNIPPET_SECONDS = 12
local CURL_TIMEOUT_SECONDS = 10

local is_recognizing = false
local run_counter = 0

local function escape_markup(str)
	return (str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function url_encode(str)
	str = str:gsub("\n", "\r\n")
	str = str:gsub("([^%w %-%_%.~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
	return (str:gsub(" ", "+"))
end

local function finish_with_osd(msg, duration)
	is_recognizing = false
	if msg then
		mp.osd_message(msg, duration or 3)
	else
		mp.osd_message("", 0)
	end
end

local function get_audio_source()
	local tracks = mp.get_property_native("track-list", {})
	for _, track in ipairs(tracks) do
		if track.selected and track.type == "audio" and track.external and track["external-filename"] then
			return track["external-filename"], true, nil
		end
	end

	local source = mp.get_property("stream-open-filename")
	if not source or source == "" or source:match("^edl://") or source:match("^av://") or source:match("^memory://") then
		source = mp.get_property("path")
	end

	local aid = mp.get_property_number("aid")
	return source, false, aid
end

local function extract_metadata(track)
	local title = (type(track.title) == "string" and track.title ~= "") and track.title or "Unknown Title"
	local artist = (type(track.subtitle) == "string") and track.subtitle or ""

	local album, released
	if type(track.sections) == "table" then
		for _, section in ipairs(track.sections) do
			if section.type == "SONG" and type(section.metadata) == "table" then
				for _, item in ipairs(section.metadata) do
					if item.title == "Album" and type(item.text) == "string" and item.text ~= "" then
						album = item.text
					elseif item.title == "Released" and type(item.text) == "string" and item.text ~= "" then
						released = item.text
					end
				end
			end
		end
	end

	local body_lines = {}
	if artist ~= "" then
		body_lines[#body_lines + 1] = escape_markup(artist)
	end
	if album and released then
		body_lines[#body_lines + 1] = escape_markup(string.format("%s (%s)", album, released))
	elseif album then
		body_lines[#body_lines + 1] = escape_markup(album)
	elseif released then
		body_lines[#body_lines + 1] = escape_markup(released)
	end

	local cover_url
	if type(track.images) == "table" then
		cover_url = track.images.coverarthq or track.images.coverart or track.images.background
	end
	if not cover_url and type(track.share) == "table" then
		cover_url = track.share.image
	end

	return {
		title = title,
		artist = artist,
		body = table.concat(body_lines, "\n"),
		cover_url = cover_url,
	}
end

local function send_notification(meta, cover_path)
	local query = (meta.artist ~= "") and (meta.title .. " " .. meta.artist) or meta.title
	local yt_url = "https://www.youtube.com/results?search_query=" .. url_encode(query)

	-- Run detached so clicking "Search on YouTube" still works after mpv closes.
	local notify_script = [[
		cover="$1"
		summary="$2"
		body="$3"
		url="$4"
		if [ -n "$cover" ] && [ -s "$cover" ]; then
			action=$(notify-send -a "SongRec" -i "$cover" -A "youtube=Search on YouTube" -- "$summary" "$body")
		else
			action=$(notify-send -a "SongRec" -i "audio-x-generic" -A "youtube=Search on YouTube" -- "$summary" "$body")
		fi
		if [ "$action" = "youtube" ]; then
			xdg-open "$url" >/dev/null 2>&1 &
		fi
		if [ -n "$cover" ]; then
			rm -f -- "$cover"
		fi
	]]

	mp.command_native({
		name = "subprocess",
		detach = true,
		args = {
			"sh",
			"-c",
			notify_script,
			"_",
			cover_path or "",
			meta.title,
			meta.body,
			yt_url,
		},
	})

	finish_with_osd(nil)
end

local function run_songrec(audio_tmp, cover_tmp)
	mp.command_native_async({
		name = "subprocess",
		playback_only = false,
		capture_stdout = true,
		capture_stderr = true,
		args = { "songrec", "audio-file-to-recognized-song", audio_tmp },
	}, function(success, res, err)
		os.remove(audio_tmp)

		if not success or not res or res.status ~= 0 then
			local detail = err or (res and res.stderr) or "unknown error"
			mp.msg.error("songrec failed: " .. detail)
			finish_with_osd("SongRec: Recognition failed", 3)
			return
		end

		local data = utils.parse_json(res.stdout or "")
		if not data or type(data.matches) ~= "table" or #data.matches == 0 or type(data.track) ~= "table" then
			finish_with_osd("SongRec: No match found", 3)
			return
		end

		local meta = extract_metadata(data.track)
		if not meta.cover_url or meta.cover_url == "" then
			send_notification(meta, nil)
			return
		end

		mp.command_native_async({
			name = "subprocess",
			playback_only = false,
			capture_stderr = true,
			args = {
				"curl",
				"-fsSL",
				"--max-time",
				tostring(CURL_TIMEOUT_SECONDS),
				"-o",
				cover_tmp,
				meta.cover_url,
			},
		}, function(dl_ok, dl_res)
			local info = utils.file_info(cover_tmp)
			if dl_ok and dl_res and dl_res.status == 0 and info and info.size and info.size > 0 then
				send_notification(meta, cover_tmp)
			else
				os.remove(cover_tmp)
				send_notification(meta, nil)
			end
		end)
	end)
end

local function recognize_song()
	if is_recognizing then
		mp.osd_message("SongRec: Already recognizing...", 2)
		return
	end

	local source, is_external, aid = get_audio_source()
	if not source or source == "" then
		mp.osd_message("SongRec: No media loaded", 3)
		return
	end

	is_recognizing = true
	run_counter = run_counter + 1
	mp.osd_message("Recognizing song...", 30)

	local pid = utils.getpid()
	local audio_tmp = string.format("/tmp/mpv-songrec-%d-%d.wav", pid, run_counter)
	local cover_tmp = string.format("/tmp/mpv-songrec-%d-%d.jpg", pid, run_counter)

	local time_pos = mp.get_property_number("time-pos", 0) or 0
	local duration = mp.get_property_number("duration", 0) or 0
	local start_pos = time_pos
	if duration > 0 and time_pos > duration - SNIPPET_SECONDS then
		start_pos = math.max(0, duration - SNIPPET_SECONDS)
	end

	local ffmpeg_args = {
		"ffmpeg",
		"-y",
		"-hide_banner",
		"-loglevel",
		"error",
		"-ss",
		string.format("%.3f", start_pos),
		"-i",
		source,
	}

	if not is_external and aid and aid >= 1 then
		ffmpeg_args[#ffmpeg_args + 1] = "-map"
		ffmpeg_args[#ffmpeg_args + 1] = string.format("0:a:%d?", aid - 1)
	end

	local extra = {
		"-t",
		tostring(SNIPPET_SECONDS),
		"-vn",
		"-acodec",
		"pcm_s16le",
		"-ar",
		"44100",
		"-ac",
		"1",
		audio_tmp,
	}
	for _, v in ipairs(extra) do
		ffmpeg_args[#ffmpeg_args + 1] = v
	end

	mp.command_native_async({
		name = "subprocess",
		playback_only = false,
		capture_stderr = true,
		args = ffmpeg_args,
	}, function(success, res, err)
		local info = utils.file_info(audio_tmp)
		if not success or not res or res.status ~= 0 or not info or not info.size or info.size == 0 then
			os.remove(audio_tmp)
			local detail = err or (res and res.stderr) or "ffmpeg extraction failed"
			mp.msg.error("ffmpeg failed: " .. detail)
			finish_with_osd("SongRec: Failed to capture audio", 3)
			return
		end

		run_songrec(audio_tmp, cover_tmp)
	end)
end

mp.add_key_binding("F2", "recognize_song", recognize_song)
