#!/usr/bin/env nu
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2026

def format []: datetime -> string {
	$in
	| date to-timezone 'UTC'
	| format date "%Y-%m-%dT%H:%M:%SZ"
}

export def events [
	--time-min: datetime = (2025-01-01T00:00:00Z) # Minimum time for events (default: 2025-01-01T00:00:00Z).
	--time-max: datetime = (2025-12-31T00:00:00Z) # Maximum time for events (default: 2025-12-31T00:00:00Z).
]: nothing -> nothing {

	let time_min = $time_min | format
	let time_max = $time_max | format

	run-external ...[
		calendar3
		events
		list
		primary
		-p ('time-min=' + $time_min)
		-p ('time-max=' + $time_max)
	]
	| from json
}