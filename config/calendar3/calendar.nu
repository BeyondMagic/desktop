#!/usr/bin/env -S nu --stdin
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2026

# Format a datetime value to the required string format for API requests.
def format-time []: datetime -> string {
	$in
	| date to-timezone 'UTC'
	| format date "%Y-%m-%dT%H:%M:%SZ"
}

# Format the event time based on the available fields (dateTime and timeZone or date).
def format-item-time []: any -> string {

	let input = $in

	if ('dateTime' in $input and 'timeZone' in $input) {
		$input.dateTime
		| into datetime
		| date to-timezone $input.timeZone
	} else {
		$input.date
		| into datetime
	}
}

# Fetch calendar events from the specified calendar and time range.
export def "main events" [
	--calendar: string = 'primary' # Calendar to fetch events from (default: primary).
	--time-min: datetime = (2025-01-01T00:00:00Z) # Minimum time for events (default: 2025-01-01T00:00:00Z).
	--time-max: datetime = (2025-12-31T00:00:00Z) # Maximum time for events (default: 2025-12-31T00:00:00Z).
	--json = false # Whether to output events in JSON format (default: false).
]: nothing -> any {

	let time_min = $time_min | format-time
	let time_max = $time_max | format-time

	let result = run-external ...[
		calendar3
		events
		list
		$calendar
		-p ('time-min=' + $time_min)
		-p ('time-max=' + $time_max)
	]
	| from json
	| get 'items'
	| default null 'summary' 'description'
	| select 'start' 'end' 'summary' 'description' 'eventType' 'id'
	| rename --column { 'eventType': 'event_type' }
	| update 'start' { $in | format-item-time }
	| update 'end' { $in | format-item-time }
	| sort-by 'start' 'end'

	if $json {
		$result | to json
	} else {
		$result
	}
}

# Main function (not used in this script, but required for NuShell scripts).
export def main []: nothing -> nothing {
	null
}
