# ANSI colour shortcuts
const A = {
	reset:   "\e[0m"
	 dim:	 "\e[2m"
	 green:   "\e[32m"
	 yellow:  "\e[33m"
	 cyan:	"\e[36m"
	 grey:	"\e[90m"
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

export def "pick" [
	--by-frequency  # Sort by visit count instead of recency.
	--max: int # Override the history limit for this invocation.
]: nothing -> string {

	let hist_path = ($nu.cache-dir | path join "nu-dir-history.json")
	let max = ($max | default 1000)

	mut hist = (open $hist_path | default [])

	# Sort: by default newest first; with --by-frequency, most-visited first.
	$hist = if $by_frequency {
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

	# Field 2 (index 1 after split) is the plain path.
	$selected
	| ansi strip  # remove ANSI from field 1 (field 2 has none anyway)
	| split row "  "
	| get --optional 1
}

export def --env main [
	--by-frequency
	--max: int
] {
	let target = (pick --by-frequency=$by_frequency --max=$max)
	if ($target | is-not-empty) {
		cd $target
	}
}
