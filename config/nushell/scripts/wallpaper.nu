# BeyondMagic © João Farias 2024 <beyondmagic@mail.ru>

# List all wallpapers files.
#
# If folder glob is not passed, then use environment WALLPAPER_FILES variable.
export def list [
	folder?: string # Folder of wallpapers.
	--all # Return also hidden files.
]: nothing -> list<string> {

	# Use environment WALLPAPER_FILES to 
	let wallpapers = if ($folder | is-empty) {
		$env.WALLPAPER_FILES
	} else {
		$folder
	}

	glob $wallpapers --no-dir
}

# Set wallpaper given path.
#
# TODO:
#	- Auto complete the types for the `--transition-type` flag.
export def set [
	--transition-type : string = 'any' # In which to perform transition when setting the wallpaper.
]: string -> nothing {
	let $file = $in

	[
		img $file
		--transition-type $transition_type
	]
	| main
}

# Run list of command of wallpaper manager.
def main []: list<string> -> any {
	let args = $in
	# See manual for awww(1).
	# The repository can be found at: https://codeberg.org/LGFae/awww
	^awww ...$args
}
