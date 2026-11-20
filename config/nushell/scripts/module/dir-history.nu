export const DIR_HISTORY_MAX = 5000
const DIR_HISTORY_STALE_AGE = 30day
const DIR_HISTORY_DEDUP_WINDOW = 5sec
const LOCK_TIMEOUT = 1sec
const LOCK_STALE_AGE = 10sec

# ANSI colour shortcuts
const A = {
	reset:   "\e[0m"
	 dim:	 "\e[2m"
	 green:   "\e[32m"
	 yellow:  "\e[33m"
	 cyan:	"\e[36m"
	 grey:	"\e[90m"
}

def history-path []: nothing -> path {
	$nu.cache-dir | path join "nu-dir-history.json"
}

def lock-path []: nothing -> path {
	$nu.cache-dir | path join "nu-dir-history.lock"
}

def load-history [hist_path: path]: nothing -> list<record> {
	if not ($hist_path | path exists) {
		return []
	}
	try {
		open $hist_path | default []
	} catch {
		[]
	}
}

def save-history [hist: list<record>, hist_path: path]: nothing -> nothing {
	let tmp_file = $"($hist_path).($nu.pid).tmp"
	$hist | to json | save --force --raw $tmp_file
	^mv -f $tmp_file $hist_path
}

# Acquire an atomic mkdir lock so concurrent Nushell and Yazi writes never race.
def with-history-lock [action: closure]: nothing -> any {
	let lock_dir = (lock-path)
	mkdir ($lock_dir | path dirname)

	let deadline = ((date now) + $LOCK_TIMEOUT)
	mut acquired = false

	while (date now) < $deadline {
		if (^mkdir $lock_dir | complete | get exit_code) == 0 {
			$acquired = true
			break
		}

		let modified = try {
			ls --directory $lock_dir | get 0.modified
		} catch {
			null
		}
		if ($modified | is-not-empty) and ((date now) - $modified) > $LOCK_STALE_AGE {
			try { ^rm -rf $lock_dir }
			continue
		}

		sleep 10ms
	}

	if not $acquired {
		return null
	}

	try {
		let result = (do $action)
		try { ^rm -rf $lock_dir }
		$result
	} catch {|err|
		try { ^rm -rf $lock_dir }
		error make { msg: $err.msg }
	}
}

# Returns the ANSI escape prefix for a given visit count.
# Colours go grey → yellow → orange → red as the count grows.
def "count-color" [
	n: int
]: nothing -> string {
	match $n {
		$c if $c <= 1   => "\e[2;37m"       # dim grey  – visited once
		$c if $c <= 3   => "\e[38;5;245m"   # grey
		$c if $c <= 5   => "\e[38;5;250m"   # bright grey
		$c if $c <= 9   => "\e[38;5;220m"   # yellow
		$c if $c <= 19  => "\e[38;5;214m"   # light orange
		$c if $c <= 49  => "\e[38;5;208m"   # orange
		$c if $c <= 99  => "\e[38;5;202m"   # deep orange
		$c if $c <= 199 => "\e[38;5;196m"   # red
		_               => "\e[1;38;5;196m" # bold red — the fan favourites
	}
}

# Sort directory history entries by frecency: count / (age_in_days + 1.0).
export def "sort-by-frecency" []: any -> any {
	let items = $in
	if ($items | is-empty) {
		return []
	}

	let now = (date now)

	$items
	| insert frecency {|row|
		let raw_age = (($now - ($row.last_visit | into datetime)) / 1day)
		let age_days = if $raw_age < 0 { 0.0 } else { $raw_age }
		$row.count / ($age_days + 1.0)
	}
	| sort-by frecency --reverse
	| reject frecency
}

# Record a directory visit with locking, 5s deduplication, and tiered eviction.
export def "record" [
	dir: string # Directory path to record.
]: nothing -> nothing {
	if ($dir | is-empty) {
		return
	}

	let expanded = ($dir | path expand)
	if not ($expanded | path exists) or ($expanded | path type) != 'dir' {
		return
	}

	let hist_path = (history-path)

	with-history-lock {
		mut hist = (load-history $hist_path)
		let now = (date now)

		let existing = ($hist | where path == $expanded | get --optional 0)
		if ($existing | is-not-empty) {
			let elapsed = ($now - ($existing.last_visit | into datetime))
			if $elapsed >= 0sec and $elapsed < $DIR_HISTORY_DEDUP_WINDOW {
				return
			}

			$hist = ($hist | each {|row|
				if $row.path == $expanded {
					$row
					| update count ($row.count + 1)
					| update last_visit $now
				} else {
					$row
				}
			})
		} else {
			$hist = ($hist | append {
				path: $expanded
				count: 1
				last_visit: $now
			})
		}

		# Enforce the maximum size via a tiered eviction pipeline:
		#   1. Drop non-existent paths.
		#   2. Drop stale single-visit entries (count == 1 and older than 30 days).
		#   3. Trim remaining entries by frecency score, keeping the top DIR_HISTORY_MAX.
		if ($hist | length) > $DIR_HISTORY_MAX {
			$hist = ($hist | where { $in.path | path exists })

			if ($hist | length) > $DIR_HISTORY_MAX {
				let cutoff = ($now - $DIR_HISTORY_STALE_AGE)
				$hist = ($hist | where {|row|
					not ($row.count == 1 and ($row.last_visit | into datetime) < $cutoff)
				})
			}

			if ($hist | length) > $DIR_HISTORY_MAX {
				$hist = ($hist | sort-by-frecency | first $DIR_HISTORY_MAX)
			}
		}

		save-history $hist $hist_path
	} | ignore
}

export def "pick" [
	--by-frequency  # Sort by visit count instead of recency.
	--by-frecency   # Sort by frecency score (frequency + recency).
	--max: int # Override the history limit for this invocation.
]: nothing -> string {

	let hist_path = (history-path)
	let max = ($max | default $DIR_HISTORY_MAX)

	# Lazy cleanup: drop entries whose directories no longer exist on disk.
	mut hist = (with-history-lock {
		let current = (load-history $hist_path)
		let filtered = ($current | where { $in.path | path exists })
		if ($filtered | length) != ($current | length) {
			save-history $filtered $hist_path
		}
		$filtered
	} | default [])

	if ($hist | is-empty) {
		return ""
	}

	# Sort: by default newest first; with --by-frecency, frecency score; with --by-frequency, most-visited first.
	$hist = if $by_frecency {
		$hist | sort-by-frecency
	} else if $by_frequency {
		$hist | sort-by count --reverse
	} else {
		$hist | sort-by last_visit --reverse
	}

	# Limit the number of candidates sent to fzf.
	$hist = ($hist | first $max)

	# ---- Build coloured display lines --------------------------------
	# Field 1 (shown):  [N]  /path/to/dir   2026-11-12 10:30
	# Field 2 (hidden): plain path
	let lines = ($hist | each {|row|
		let count_col = (count-color $row.count)
		let date_str  = ($row.last_visit | format date '%Y-%m-%d %H:%M')
		let display   = [
			$"($count_col)[($row.count)]($A.reset)"
			$"($A.cyan)($row.path)($A.reset)"
			$"($A.dim)($date_str)($A.reset)"
		] | str join "  "
		$"($display)\t($row.path)"
	} | str join (char newline))

	# ---- Pick the best preview command available ---------------------
	# eza is the prettiest; lsd is close; GNU ls with --color=always is
	# the safe fallback (^ls forces the external binary, bypassing
	# Nushell's table-formatted `ls`).
	let preview_cmd = if (which eza | is-not-empty) {
		"eza --tree --level=2 --icons --group-directories-first --color=always {2}"
	} else if (which lsd | is-not-empty) {
		"lsd --tree --depth=2 --color=always {2}"
	} else {
		"^ls -la --color=always {2}"
	}

	 # ---- Run fzf -----------------------------------------------------
	let selected = (
		$lines
		| fzf --ansi
			  --scheme=path
			  --delimiter "\t"
			  --with-nth 1
			  --prompt "  CD  ➜  "
			  --pointer "  "
			  --marker "  "
			  --border rounded
			  --border-label " Recent Directories "
			  --border-label-pos 2
			  --preview $preview_cmd
			  --preview-window "right:55%:wrap"
			  --preview-label " Preview "
			  --color "fg:white,bg:-1,hl:magenta,fg+:bright-white,bg+:-1,hl+:bright-magenta,prompt:yellow,pointer:bright-yellow,marker:green,spinner:cyan,info:cyan,header:grey,border:bright-black,label:cyan"
			  --height 80%
			  --layout reverse
			  --info inline-right
			  --separator "─"
		| str trim
	)

	if ($selected | is-empty) {
		return ""
	}

	echo $selected

	# Field 2 (index 1 after split) is the plain path.
	$selected
	| ansi strip  # remove ANSI from field 1 (field 2 has none anyway)
	| split row "  "
	| get --optional 1
}

export def --env main [
	--by-frequency
	--by-frecency
	--max: int
] {
	let target = (pick --by-frequency=$by_frequency --by-frecency=$by_frecency --max=$max)
	if ($target | is-not-empty) {
		cd $target
	}
}
