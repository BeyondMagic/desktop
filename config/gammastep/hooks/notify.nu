#!/usr/bin/env -S nu --stdin
#
# João V. Farias © BeyondMagic <beyondmagic@mail.ru> 2024

export def main [
	event: string # What event is.
	old: string # Old period.
	new: string # New period.
]: nothing -> nothing {
	let message = match $event {
		"period-changed" => ($old + " to " + $new),
		_ => "Uknown"
	}

	^notifiy-send $event $message
}
