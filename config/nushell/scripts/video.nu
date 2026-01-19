#!/usr/bin/env nu
#
# BeyondMagic © João Farias 2024 <beyondmagic@mail.ru>

# Extract name from file.
def extract-name []: string -> string {
	$in
	| path basename
	| split row '.'
	| drop 1
	| get 0
}

# Convert video MKV to MP4.
export def mkv-to-mp4 [
	input: string # Video MKV to convert.
	output: string # Video MP4 made.
]: nothing -> nothing {
	^ffmpeg -i $input -c:a aac -c:v copy $output
}

# Convert GIF to WEBP.
export def gif-to-webp [
	input: string # Video to convert.
]: nothing -> nothing {
	let out = $input
		| extract-name

	^ffmpeg -i $input -vcodec webp -loop 0 -pix_fmt yuva420p ($out + '.webp')
}

# Convert video to MP3.
export def to-mp3 [
	input: string # Video to convert.
]: nothing -> nothing {
	let out = $input
		| extract-name

	^ffmpeg -i $input -q:a 0 -map a ($out + '.webp')
}

# Get the duration of a video.
export def get-duration [
	input: string # Video to get duration from.
]: nothing -> float {
	# Get the duration in seconds.
	let data = (
		^ffprobe
		-v error
		-show_entries
		format=duration
		-of
		default=noprint_wrappers=1:nokey=1
		$input
	) | complete

	let duration = $data.stdout

	# Convert to integer.
	$duration
}

def timestamp-transforms []: nothing -> list<closure> {
	[
		{ $in | into duration --unit 'hr' }
		{ $in | into duration --unit 'min' }
		{ $in | into duration --unit 'sec' }
		{ $in | into duration --unit 'ms' }
	]
}

def parse-timestamp [
	timestamp: string
]: nothing -> duration {
	use ./standard/transform.nu

	$timestamp
	| split row --regex ':|\.'
	| transform (timestamp-transforms)
	| math sum
}

# Download video.
#
# Dependes on:
#	- yt-dlp : https://github.com/yt-dlp/yt-dlp
#
# Examples:
#
# Will use the piped link.
#	$ 'https://www.youtube.com/watch?...' | video download
#
# Will use the current content from clipboard.
#	$ 'https://www.youtube.com/watch?...' | wl-copy
#	$ video download
export def download [
	name? : string # Name of the file.
	--link: string # Link of the video to download (taken from clipboard if empty).
	--archive: string = './archive.txt' # Archive file for successful downloads.
	--archive-failed: string = './archive-failed.txt' # Archive file for failed downloads.
	--format: string = 'vcodec:h264,res,acodec:m4a' # Format of video and audio.
	--cookies-from-browser: string = 'firefox' # Use cookies from browser.
	--list-formats # List formats of the video.
	--extra-args : list<string> = [] # Extra arguments to pass to yt-dlp.
	--playlist # Download playlist.
]: nothing -> any {
	let file_name = if ($name | is-empty) {
		[]
	} else {
		[-o ((date now | format date '%y-%m-%d_%H_%M_%S') + '_' + $name)]
	}
	
	let link = if ($link | is-empty) {
		^wl-paste
	} else {
		$link
	}

	let archive_failed_path = $archive_failed
		| path expand

	mut args = [
		-S $format
		--recode mp4
		--download-archive $archive
		--js-runtimes bun
		--remote-components ejs:github
		#--extractor-arg "youtube:player_client=tv"
		--add-metadata
		--embed-thumbnail
		--embed-metadata
		--embed-chapters
		--sub-langs 'all'
		--embed-subs
		-i
		$link
		...$file_name
	]

	# Fix ffmpeg bug with nicovideo links due to disallowed extensions.
	# https://github.com/yt-dlp/yt-dlp/issues/12700
	if $link =~ 'nicovideo' {
		$args = $args ++ [
			--downloader-arg
			"ffmpeg_i1:-extension_picky 0"
			--downloader-arg
			"ffmpeg_i2:-extension_picky 0"
		]
	}

	if (not $playlist) {
		$args = $args ++ [
			--no-playlist
		]
	}

	if ($cookies_from_browser | is-not-empty) {
		$args = $args ++ [
			--cookies-from-browser $cookies_from_browser
			--extractor-args youtubetab:skip=authcheck
		]
	}

	if $list_formats {
		$args = $args ++ [
			--list-formats
		]
	}

	if ($extra_args | is-not-empty) {
		$args = $args ++ $extra_args
	}

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

# Make subvideo from start to end.
#
# Examples:
#	$ video subvideo `a.mkv` --start 00:00:01 --end 00:00:10
export def subvideo [
	file : string # Input file for video as path.
	--start : string # Start timestamp in HH:mm:ss.SSS format.
	--end : string # End timestamp in HH:mm:ss.SSS format.
	--output : string # Output file for video as path.
]: nothing -> nothing {
	# Raise error when start timestamp is not given.
	if ($start | is-empty) {
		error make {
			msg: "Not given start time stamp."
			label: {
				text: "You must specify the start time stamp of the video."
				span: (metadata $start).span
			}
		}
	}

	# Raise error when end timestamp is not given.
	if ($end | is-empty) {
		error make {
			msg: "Not given end time stamp."
			label: {
				text: "You must specify the end time stamp of the video."
				span: (metadata $end).span
			}
		}
	}

	let start_duration = parse-timestamp $start
	let end_duration = parse-timestamp $end

	let duration = $end_duration - $start_duration

	if $duration < 0sec {
		error make {
			msg: "End time stamp is before start time stamp."
			label: {
				text: "The end time stamp must be after the start time stamp."
				span: (metadata $end).span
			}
		}
	}

	let duration_time = {
		hr: ($duration // 1hr)
		min: (($duration mod 1hr) // 1min)
		sec: (($duration mod 1min) // 1sec)
		ms: (($duration mod 1sec) // 1ms)
	}

	let formatted_duration = (
		($duration_time.hr | into string | fill --alignment 'right' --character '0' --width 2) + ':' +
		($duration_time.min | into string | fill --alignment 'right' --character '0' --width 2) + ':' +
		($duration_time.sec | into string | fill --alignment 'right' --character '0' --width 2) + '.' +
		($duration_time.ms | into string | fill --alignment 'right' --character '0' --width 3)
	)

	let out = if ($output | is-empty) {
		let parsed = $file | path parse
		let random_suffix = random chars --length 3
		let ext = if ($parsed.extension | is-empty) { '' } else { '.' + $parsed.extension }
		let filename = $parsed.stem + '-' + $random_suffix + $ext

		if ($parsed.parent | is-empty) {
			$filename
		} else {
			[$parsed.parent $filename] | path join
		}
	} else {
		$output
	}

	main [
		-ss $start
		-i $file
		-c copy
		-to $formatted_duration
		$out
	]
}

const default_video_flags = [
	-c copy
	-map 0
	-reset_timestamps 1
]

# Split video by different segments with a duration.
#
# Dependes on:
#	- ffmpeg
#
# Input path of file is piped in standard input.
#
# Examples:
#	> 'video.mp4' | video split 2min new_video.mp4
#
# Read more information about flags in ffmpeg manual(s).
export def split [
	segment : duration # Duration of each segment.
	out : string # Name of file to save in.
	--flags : list<string> = $default_video_flags # Flags for ffmpeg.
	--segment-format : string = '-%03d' # Specifier of each segmented video.
	--extension : string # If not specified, will default to that of the file.
]: string -> nothing {
	let piped = $in

	if not ($piped | path exists) or ($piped | path type) != 'file' {
		error make {
			msg: "Failed to parse input."
			label: {
				text: "Is not a file or does not exist."
				span: (metadata $piped).span
			}
		}
	}

	let micro_seconds = (($segment | into int) / 1000) | into string

	let type = if ($extension | describe) == nothing {
		$piped | split row '.' | last
	} else {
		$extension
	}

	main [
		-i $piped
		...$flags
		-segment_time ($micro_seconds + 'us')
		-f segment
		($out + $segment_format + '.' + $type)
	]
}

# The main comand used for video.
def main [
	args : list<any> # Arguments to be given for the main command.
]: nothing -> nothing {
	^ffmpeg ...$args
}
