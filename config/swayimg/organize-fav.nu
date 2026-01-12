#!/usr/bin/env -S nu --stdin
#
# João F. Farias © 2025 BeyondMagic <beyondmagic@mail.ru>

def main []: string -> any {
	let base = if ('IMAGES_FOLDER' in $env) {
		$env.IMAGES_FOLDER
	} else {
		$env.HOME
	}

	let image_locations = if ('IMAGE_LOCATIONS' in $env) {
		$env.IMAGE_LOCATIONS | split row ':'
	} else {
		[($base + '/')]
	}

	let to = $image_locations
		| str replace $base ''
		| str join "\n"
		| ^fuzzel --dmenu

	if ($to | is-empty) {
		exit 1
	}

	mv $in ($base + $to | path expand)
}