#!/usr/bin/env -S nu --stdin
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2026

# List of trashed files.
export def list [
	--sizes # Show the disk usage sizes of all items.
]: nothing -> table<datetime: datetime, path: string> {
	let data = run-external trash-list
		| lines
		| split column ' ' --number 3 'date' 'time' 'path'
		| where {
			$in.path | path exists
		}
		| insert datetime {
			$in.date + 'T' + $in.time
			| into datetime
		}
		| select datetime path

	if not $sizes {
		return $data
	}

	$data
	| insert size {
		du $in.path
		| select apparent physical
		| first
	}
	| flatten
	| sort-by physical apparent
}
