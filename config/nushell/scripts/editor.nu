# Editor command for Neovim, with session management and fzf integration.
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2024-2026

const MAX_SESSIONS = 25

def sessions-dir []: nothing -> string {
	let state_home = ($env.XDG_STATE_HOME? | default ('~/.local/state' | path expand))
	$state_home | path join 'nvim' 'sessions'
}

def shorten-home [path: string]: nothing -> string {
	let home = ($env.HOME | path expand | str trim --right --char '/')
	if $path == $home {
		'~'
	} else if ($path | str starts-with $"($home)/") {
		'~' + ($path | str substring ($home | str length)..)
	} else {
		$path
	}
}

def format-relative-age [ts: int]: nothing -> string {
	let now = ((date now) | format date '%s' | into int)
	let diff = ([0 ($now - $ts)] | math max)
	if $diff < 60 {
		'just now'
	} else if $diff < 3600 {
		$"($diff // 60)m ago"
	} else if $diff < 86400 {
		$"($diff // 3600)h ago"
	} else if $diff < (86400 * 30) {
		$"($diff // 86400)d ago"
	} else {
		$"($ts)000000000" | into int | into datetime | date to-timezone local | format date '%Y-%m-%d'
	}
}

def unescape-vim-path [raw: string]: nothing -> string {
	let unescaped = ($raw | str replace --all '\ ' ' ' | str replace --all '\\' '\')
	if ($unescaped == '~') or ($unescaped | str starts-with '~/') {
		$unescaped | path expand
	} else {
		$unescaped
	}
}

def parse-vim-fallback [vim_path: string]: nothing -> record {
	let mtime = try {
		ls $vim_path | get 0.modified | format date '%s' | into int
	} catch {
		0
	}

	mut cwd = ($env.HOME | path expand)
	mut files = []
	mut active_file = ''

	let lines = try { open --raw $vim_path | lines } catch { [] }
	for line in $lines {
		if ($line | str starts-with 'cd ') {
			let raw_cd = ($line | str substring 3.. | str trim)
			$cwd = (unescape-vim-path $raw_cd)
		} else if ($line | str starts-with 'badd ') {
			let raw_file = ($line | str replace --regex '^badd\s+\+?\d*\s+' '' | str trim)
			let expanded = (unescape-vim-path $raw_file)
			let resolved = if ($expanded | str starts-with '/') or ($expanded =~ '^\w+://') {
				$expanded
			} else {
				$cwd | path join $expanded | path expand
			}
			if ($resolved | is-not-empty) and ($resolved not-in $files) {
				$files = ($files | append $resolved)
			}
		} else if ($line | str starts-with 'edit ') {
			let raw_file = ($line | str substring 5.. | str trim)
			let expanded = (unescape-vim-path $raw_file)
			let resolved = if ($expanded | str starts-with '/') or ($expanded =~ '^\w+://') {
				$expanded
			} else {
				$cwd | path join $expanded | path expand
			}
			if ($resolved | is-not-empty) {
				$active_file = $resolved
				if ($resolved not-in $files) {
					$files = ($files | append $resolved)
				}
			}
		}
	}

	if ($active_file | is-empty) and ($files | is-not-empty) {
		$active_file = ($files | get 0)
	}

	{
		session: $vim_path
		cwd: $cwd
		updated_at: $mtime
		active_file: $active_file
		files: $files
	}
}

def load-sessions []: nothing -> list<record> {
	let dir = (sessions-dir)
	let vim_paths = if ($dir | path exists) {
		ls $dir | where type == file and ($it.name | str ends-with '.vim') | get name
	} else {
		[]
	}

	let candidates = if ($vim_paths | is-not-empty) {
		$vim_paths
	} else {
		let legacy = ('~/.config/nvim/session.vim' | path expand)
		if ($legacy | path exists) { [ $legacy ] } else { [] }
	}

	$candidates
	| each {|vim_path|
		let meta_path = ($vim_path | str replace --regex '\.vim$' '.meta.json')
		let meta = if ($meta_path | path exists) {
			try { open $meta_path } catch { null }
		} else {
			null
		}
		if $meta != null {
			let mtime = try { ls $vim_path | get 0.modified | format date '%s' | into int } catch { 0 }
			let files = ($meta.files? | default [])
			let active_file = ($meta.active_file? | default (if ($files | is-not-empty) { $files | get 0 } else { '' }))
			{
				session: $vim_path
				cwd: ($meta.cwd? | default ($env.HOME | path expand))
				updated_at: (($meta.updated_at? | default $mtime) | into int)
				active_file: $active_file
				files: $files
			}
		} else {
			parse-vim-fallback $vim_path
		}
	}
	| sort-by updated_at --reverse
	| first $MAX_SESSIONS
}

def build-session-preview [row: record]: nothing -> string {
	let updated_str = ($"($row.updated_at)000000000" | into int | into datetime | date to-timezone local | format date '%Y-%m-%d %H:%M:%S')
	let age = (format-relative-age $row.updated_at)
	let cwd_short = (shorten-home $row.cwd)
	let header = [
		$"Directory: ($cwd_short)"
		$"Updated:   ($updated_str) \(($age)\)"
		$"Session:   (shorten-home $row.session)"
		""
		$"Files \(($row.files | length)\):"
	]
	let file_lines = if ($row.files | is-empty) {
		[ "  (none)" ]
	} else {
		$row.files | each {|f|
			let label = (shorten-home $f)
			if $f == $row.active_file {
				$"  * ($label) [active]"
			} else {
				$"    ($label)"
			}
		}
	}
	$header | append $file_lines | str join (char newline) | encode base64
}

def pick-session [sessions: list<record>]: nothing -> string {
	let A = {
		reset: (ansi reset)
		dim: (ansi dark_gray)
		cyan: (ansi cyan)
		green: (ansi green)
	}

	let lines = (
		$sessions
		| each {|row|
			let age = (format-relative-age $row.updated_at | fill --alignment left --width 10)
			let cwd_short = (shorten-home $row.cwd)
			let count = ($row.files | length)
			let count_label = if $count == 1 { '1 file' } else { $"($count) files" }
			let active_name = if ($row.active_file | is-not-empty) {
				$row.active_file | path basename
			} else {
				''
			}
			let summary = if ($active_name | is-not-empty) {
				$"($count_label) · ($active_name)"
			} else {
				$count_label
			}
			let display = $"($A.dim)($age)($A.reset)  ($A.cyan)($cwd_short)($A.reset)  ($A.dim)\(($summary)\)($A.reset)"
			let preview_b64 = (build-session-preview $row)
			$"($display)\t($row.session)\t($preview_b64)"
		}
		| str join (char newline)
	)

	let selected = try {
		(
			$lines
			| fzf --ansi
				--nth 1
				--delimiter "\t"
				--with-nth 1
				--prompt "  SESSION  ➜  "
				--pointer "  "
				--marker "  "
				--border rounded
				--border-label " Recent Neovim Sessions "
				--border-label-pos 2
				--preview "echo {3} | base64 -d"
				--preview-window "right:50%:wrap"
				--preview-label " Preview "
				--color "fg:white,bg:-1,hl:magenta,fg+:bright-white,bg+:-1,hl+:bright-magenta,prompt:yellow,pointer:bright-yellow,marker:green,spinner:cyan,info:cyan,header:grey,border:bright-black,label:cyan"
				--height 80%
				--layout reverse
				--info inline-right
				--separator "─"
			| str trim
		)
	} catch {
		''
	}

	if ($selected | is-empty) {
		return ''
	}

	$selected | split row (char tab) | get --optional 1 | default ''
}

def resolve-explicit-session [spec: string]: nothing -> string {
	let expanded = ($spec | path expand)
	if ($expanded | path exists) {
		return $expanded
	}

	let dir = (sessions-dir)
	let matches = (
		[
			($dir | path join $spec)
			($dir | path join $"($spec).vim")
		]
		| where {|candidate| $candidate | path exists }
	)

	if ($matches | is-empty) {
		error make { msg: $"Session not found: ($spec)" }
	} else {
		$matches | get 0
	}
}

# Restore a saved Neovim session from history (fzf picker by default).
export def --env restore [
	...files: string # Files to launch along with it.
	--session (-s): string # Explicit session file or managed session name to recover from.
	--latest (-l) # Restore the most recent saved session immediately without opening fzf.
]: nothing -> nothing {
	let target_session = if ($session | is-not-empty) {
		resolve-explicit-session $session
	} else {
		let sessions = (load-sessions)
		if ($sessions | is-empty) {
			print "No saved Neovim sessions found."
			return
		}
		if $latest {
			$sessions | get 0.session
		} else {
			let picked = (pick-session $sessions)
			if ($picked | is-empty) {
				return
			}
			$picked
		}
	}

	main --flags [
		-S $target_session
	] ...$files
}

# Launch the default editor specified by $env.EDITOR.
export def --env main [
	...files : string # Files to launch with it.
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
