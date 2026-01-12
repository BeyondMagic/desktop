#!/usr/bin/env nu
#
# BeyondMagic © João Farias 2024 <beyondmagic@mail.ru>

# Content manager.
export module content {

	# Copy the content of the file into the Wayland clipboard.
	# Needs wl-copy.
	export def copy [
		name: string # File name.
	]: nothing -> nothing {
		open --raw $name | wl-copy
	}

	# Copy the last content of the clipboard into a file.
	export def paste [
		name: string # File name.
		--force = false # Save even if it exists.
	]: nothing -> nothing {
		if $force {
			wl-paste | save --force $name
		} else {
			wl-paste | save $name
		}
	}

}

# Path manager.
export module path {

	# Copy the file path of the file.
	export def copy [
		name: string # File name
	]: nothing -> nothing {
		$name | path expand | wl-copy
	}

}

const default_flags = [
	'-adDoRJUr'
	'-T' 't'
]

# Open default file manager.
export def --env manager [
	...args : string # Argument for file manager.
	--flags : list<string> = $default_flags # Flags of file manager.
]: nothing -> nothing {
	use quitcd.nu n
	n ...$flags ...$args
}

# Display tree-like structure for folders.
export def tree []: nothing -> any {
	^ls -R
	| grep ":$"
	| sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
}
