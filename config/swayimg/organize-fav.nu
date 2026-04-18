#!/usr/bin/env -S nu --stdin
#
# João F. Farias © 2025-2026 BeyondMagic <beyondmagic@mail.ru>

# This script is used to move an image to a location specified by the user.
# It can be used in conjunction with a file manager or as a standalone script.
def main [
	path?: string # If not provided, the standard input will be used.
]: string -> any {

	let input = if ($path | is-empty) {
		$in
	} else {
		# Yazi pre-formats the path with quotes, so we need to remove them.
		$path
		| str replace --all --regex `^"|"$` ``
	}

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

	mv --force $input ($base + $to | path expand)
}