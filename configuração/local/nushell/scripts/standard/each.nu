# João Farias © BeyondMagic 2025 <beyondmagic@mail.ru>

# Resolve issue by matching all input types into a list of any type.
def standardize []: any -> any {
	let type = $in | describe --detailed | get type

	match $type {
		"nothing" | "int" | "float" | "string" | "bool" | "date" | "duration" | "binary" => $in
		"table" | "list" => $in
		"record" => $in
		"closure" => {
			error make {
				message: "Cannot standardize a closure into a list."
				label: "each.nu"
			}
		}
		_ => {
			error make {
				message: $"Unknown type: ($type). Cannot standardize into a list."
				label: "each.nu"
			}
		}
	}
}

# Run a closure for each item in the piped list, asking for user confirmation before each execution.
export def interactive [
	closure: closure # Will be called with each item.
]: list<any> -> any {
	$in | each {|it|

		let type = $it | describe

		print $"Run closure for item of type `($type)`: `"
		print $it

		mut confirmation = ""

		while true {
			if $confirmation == "y" or $confirmation == "n" {
				break
			} else {
				$confirmation = (null | input "Please enter 'y' or 'n': " | str downcase)
			}
		}

		if $confirmation == "y" {
			$it | do $closure o+>| standardize | each {|line|
				print $line
				$line
			}
		}
	}
}