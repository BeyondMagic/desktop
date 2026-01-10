export def restore [
	...files: string # Files to launch along with it.
	--session : string = '~/.config/nvim/session.vim' # Session to recover from.
]: nothing -> nothing {
	main --flags [
		-S $session
	] ...$files
}

# Launch the default editor specified by $env.EDITOR.
export def --env main [
	...files : string # Files to launch along with it.
	--flags : list<string> = [] # Flags to launch with it.
]: [list<string> -> nothing, nothing -> nothing] {
	# Determine the temp file path, matching the logic in Neovim's init.lua.
	# Check if the NEOVIM_CD key exists in the $env record.
	let temp_file = if "NEOVIM_CD" in $env {
		$env.NEOVIM_CD
	} else {
		"/tmp/nvim_cd_path"
	}

	# If a temp file exists from a previous session, remove it.
	if ($temp_file | path exists) {
		rm --force $temp_file
	}

	let input = $in

	let to = if ($input | is-not-empty) {
		$input
	} else {
		$files
	} | path expand

	^$env.EDITOR ...$to ...$flags

	# After nvim closes, check if it created the directory file
	if ($temp_file | path exists) {
		let target_dir = (open $temp_file | str trim)
		rm --force $temp_file
		if ($target_dir | is-not-empty) {
			cd $target_dir
		}
	}
}
