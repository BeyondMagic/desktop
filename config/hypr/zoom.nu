#!/usr/bin/env -S nu --stdin

export def main [
	--type: string # Type of action to perform: 'in', 'out', 'reset', 'screenshot'.
	--difference: float = 0.15 # Difference percentage for zooming in or out.
]: nothing -> any {

	use fork.nu

	let current = run-external hyprctl getoption cursor:zoom_factor '-j'
		| from json
		| get float

	# Determine the zoom action based on the input type
	let zoom = match $type {
		'in' => ($current + $difference),
		'out' => (
			[
				($current - $difference)
				(1.0)
			] | math max
		),
		'reset' => (1.0),
		'screenshot' => {
			fork {
				flameshot gui --raw
				| wl-copy
			}
			sleep 0.25sec
			1.0
		},
		_ => {
			let type_span = (metadata $type).span

			error make {
				msg: "Invalid type: $type. Use 'in', 'out', 'reset', or 'screenshot'."
				label: {
					text: "Here is the invalid type:"
					span: $type_span
				}
			}

		}
	}

	run-external hyprctl keyword cursor:zoom_factor $zoom
}
