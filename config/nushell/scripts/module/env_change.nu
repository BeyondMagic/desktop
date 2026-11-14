# ~/.config/nushell/config.nu (or a sourced module)

# Path to the directory-history file (JSON for structured counts).
const DIR_HISTORY_PATH = ($nu.cache-dir | path join "nu-dir-history.json")

# configurable maximum number of entries
const DIR_HISTORY_MAX = 100000

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

	# Enforce the maximum size: keep the most-recently-visited entries.
	if ($hist | length) > $DIR_HISTORY_MAX {
		$hist = ($hist | sort-by last_visit | last $DIR_HISTORY_MAX)
	}

	$hist | save --force $DIR_HISTORY_PATH
}]
