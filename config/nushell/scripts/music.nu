#!/usr/bin/env nu
#
# BeyondMagic © João Farias 2024 <beyondmagic@mail.ru>

const default_playlist = 'https://www.youtube.com/playlist?list=PLZx2EchsfnlgoXkZtHaNrAta_hIl4wkXA'
const default_archive = '~/armazenamento/música/youtube.log'
const default_archive_failed = '~/armazenamento/música/youtube_failed.log'
const default_folder = '~/armazenamento/música/canções/'
const default_format = '%(title)s.%(ext)s'
const default_max = 50

# Add cover to image.
export module cover {

	# FIXIT: find covers for us and shit.
	export def download [
		song : string
		author : string
	]: nothing -> nothing {
	}

	# FIXIT: make parameter and shit.
	export def set [
		file : string
		video : string
	]: nothing -> nothing {
		^ffmpeg ...[
			-i $video
			-i $file
			-map 0:0
			-map 1:0
			-c copy
			-id3v2_version 3
			-metadata:s:v title='Album cover'
			-metadata:s:v comment='Cover (front)'
			new-"$2"
		]
	}
}

# Download all songs from a playlist.
#
# Dependes on:
#	- yt-dlp : https://github.com/yt-dlp/yt-dlp
export def download [
	playlist : string = $default_playlist # Playlist link to download from.
	--archive : string = $default_archive # Archive to save all files.
	--archive-failed : string = $default_archive_failed # Archive to save all failed IDs.
	--folder : string = $default_folder # Folder to save files in.
	--format : string = $default_format # Format of files. See yt-dlp help page.
	--max : int = $default_max # Max videos to download from most updated.
]: nothing -> nothing {

	let archive_failed_path = $archive_failed
		| path expand

	let args = [
		-o ($folder | path join $format)
		--download-archive $archive
		--add-metadata
		--embed-thumbnail
		--embed-metadata
		--embed-chapters
		--cookies-from-browser firefox
		--js-runtimes bun
		# --extractor-args youtubetab:skip=authcheck
		# --extractor-args youtube:player_js_version=actual
		# --no-embed-info-json
		--sub-langs 'all'
		--embed-subs
		--playlist-end $max
		--metadata-from-title "(?P<artist>.+?) - (?P<title>.+)"
		-x
		-i $playlist
	]

	# Download the new songs to the folder.
	# Run yt-dlp with the given arguments.
	# Capture the output and print it line by line.
	let result = (run-external yt-dlp ...$args) o+e>| lines | each {|line|
		print $line

		if ($line starts-with 'ERROR: ') {
			let failed_id = $line
			| parse --regex `\[(.*?)\] (.*?):`
			| rename 'platform' 'id'
			| each {$in.platform + ' ' + $in.id}

			# If any IDs were found, append them to the failed archive file
			if ($failed_id | is-not-empty) {

				let ids = if ($archive_failed_path | path exists) {
					(open $archive_failed_path | lines) ++ $failed_id
				} else {
					$failed_id
				}

				$ids | uniq | save --force $archive_failed_path
			}
		}

		$line
	}
}

# Update database with new songs.
export def update []: nothing -> nothing {
	# Add the new songs to the MPD database.
	^mpc update --wait
}

# Manager/visualizer of music.
export def manager [
	--config : string = '~/.config/ncmpcpp/config' # Configuraiton file 
]: nothing -> nothing {
	^ncmpcpp -c $config --ignore-config-errors
}

# Find a song.
## Load a song that you found from a playlist
#find_song() {
#
#  # query get by dmenu
#  query="$(printf '' | dmenu -p "Find a song:")"
#
#  # if empty doesn't continue
#  [ "$query" ] || exit 1
#
#  # select all songs that it finds
#  song_found="$(mpc search any "$query")"
#
#  # if it doesn't find any song
#  [ "$song_found" ] || exit 1
#
#  # add songs
#  song_found="$(echo "$song_found" | dmenu -i -l 10 -r )"
#
#  # only continue if it did find songs
#  [ "$song_found" ] || exit 1
#
#  # last position to start counting from now (in case of multiple songs)
#  position_last=$(mpc playlist | wc -l)
#
#  # loop through all the songs to add it to mpd
#  echo "$song_found" | \
#	  while IFS="" read -r song_path || [ -n "$song_path" ]; do
#		  mpc add "$song_path"
#	  done
#
#  # start from the first song added
#  mpc play $((position_last + 1))
#
#}

# Delete song.
## Delete current song of mpd
#del_cursong() {
#
#  # A direct call :)
#  mpc del $(mpc playlist | grep -n "$(mpc current)" | cut -d : -f 1)
#
#}
