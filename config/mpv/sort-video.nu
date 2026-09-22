#!/usr/bin/env -S nu --stdin --no-config-file
#
# João V. Farias © <beyondmagic@mail.ru>

# Sort the current piped path file into the videos folder.
export def main [
	video: string # Full filepath of the video.
] : nothing -> nothing {

	let src = "~/storage/videos/"
		| path expand

	let globbed = $src | path join "**/*"

	let exclude = [
		".Trash-1000"
		"lost+found"
		"json"
		"vtt"
		"Gif"
	]

	let folders = ls --long --directory ...(glob $globbed --no-file)
		| where name != $src
		| where {|row|
			let rel = $row.name | str replace ($src + "/") ""
			let parts = $rel | split row "/"
			($parts | all {|p| $p not-in $exclude })
		}
		| sort-by modified --reverse

	let chosen = $folders
		| get name
		| str replace ($src + "/") ""
		| str join "\n"
		| fuzzel --dmenu

	let folder = $src | path join $chosen | path expand

	mv $video $folder
}
