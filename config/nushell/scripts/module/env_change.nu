# ~/.config/nushell/config.nu (or a sourced module)
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2026

# Path to the directory-history file (JSON for structured counts).
const DIR_HISTORY_PATH = ($nu.cache-dir | path join "nu-dir-history.json")

# configurable maximum number of entries
const DIR_HISTORY_MAX = 5000

# Age threshold after which single-visit entries are evicted under capacity pressure.
const DIR_HISTORY_STALE_AGE = 30day

# Ensure the file exists as an empty list.
if not ($DIR_HISTORY_PATH | path exists) {
	[] |
	save --force $DIR_HISTORY_PATH
}

# Initialize the PWD hook as an empty list if it doesn't exist
$env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

# Hook: record every directory change.
$env.config.hooks.env_change.PWD ++= [{|before, after|
	if ($after | is-empty) {
		return
	}

	# Load current history; normalise to a list.
	mut hist = (open $DIR_HISTORY_PATH | default [])

	# Find an existing entry for this path.
	let existing = ($hist | where path == $after | get --optional 0)

	if ($existing | is-not-empty) {
		# Increment count and update timestamp.

		$hist = ($hist | each {|row|
			if $row.path == $after {
				$row
				| update count ($row.count + 1)
				| update last_visit (date now)
			} else {
				$row
			}
		})
	} else {
		# Add a new entry.
		$hist = ($hist | append {
			path: $after
			count: 1
			last_visit: (date now)
		})
	}

	# Enforce the maximum size via a tiered eviction pipeline:
	#   1. Drop non-existent paths.
	#   2. Drop stale single-visit entries (count == 1 and older than 30 days).
	#   3. Trim remaining entries by frecency score, keeping the top DIR_HISTORY_MAX.
	if ($hist | length) > $DIR_HISTORY_MAX {
		$hist = ($hist | where { $in.path | path exists })

		if ($hist | length) > $DIR_HISTORY_MAX {
			let cutoff = ((date now) - $DIR_HISTORY_STALE_AGE)
			$hist = ($hist | where {|row|
				not ($row.count == 1 and ($row.last_visit | into datetime) < $cutoff)
			})
		}

		if ($hist | length) > $DIR_HISTORY_MAX {
			use ./dir-history.nu sort-by-frecency
			$hist = ($hist | sort-by-frecency | first $DIR_HISTORY_MAX)
		}
	}

	$hist | save --force $DIR_HISTORY_PATH
}]
