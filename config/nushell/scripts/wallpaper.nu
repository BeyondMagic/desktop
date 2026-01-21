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
	--transition-type: string = 'any' # In which to perform transition when setting the wallpaper.
	--outputs: list<string> # The outputs (monitor names) to set the wallpaper on.
]: string -> any {
	let outputs = if ($outputs | is-empty) {
		[]
	} else {
		[
			--outputs (
				$outputs
				| str join ','
			)
		]
	}

	[
		img $in
		...$outputs
		--transition-type $transition_type
	]
	| main
}

# Run list of command of wallpaper manager.
#
# See manual for awww(1).
# The repository can be found at: https://codeberg.org/LGFae/awww
def main []: list<string> -> any {
	run-external ...[
		'awww'
		...$in
	]
}
