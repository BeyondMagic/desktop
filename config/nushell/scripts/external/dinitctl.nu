# João V. Farias © BeyondMagic <beyondmagic@mail.ru> 2024-2026

# List services managed by dinit.
export def list []: nothing -> list<any> {
	main [
		"list"
	]
	| lines
	| parse --regex '^\[(?P<block>.{8})\]\s+(?P<name>[^\s(]+)(?:\s+\(pid:\s+(?P<pid>\d+)\))?'
	| upsert active {|it|
		# Square brackets inside the block (position 0 and 2) indicate it's marked active
		($it.block | str substring 0..0) == "["
	}
	| upsert target {|it|
        # Curly braces or square brackets on the left (index 0) mean target is Started
        let start_indicators = ["{", "["]
        if ($start_indicators | any {|s| $it.block | str starts-with $s }) {
            "Started"
        } else {
            "Stopped"
        }
    }
	| upsert status {|it|
        let b = $it.block
        if ($b | str contains "<<") {
            "Starting"
        } else if ($b | str contains ">>") {
            "Stopping"
        } else if ($b | str contains "+") {
            "Started"
        } else if ($b | str contains "s") {
            "Skipped"
        } else if ($b | str contains "X") {
            "Failed"
        } else if ($b | str contains "-") {
            "Stopped"
        } else {
            "Unknown"
        }
    }
	| reject block
	| rename --column { name: "service" }
	| update pid {|row|
	    if ($row.pid | is-not-empty) {
        	$row.pid | into int
    	}
	}
    | sort-by pid service
}

# Control and manage services monitored by dinit.
# See dinitctl manual(1).
def main [
	arguments: list<string> # Arguments to pass for external command.
]: nothing -> any {
	run-external ...[
		'dinitctl'
		...$arguments
	]
}
