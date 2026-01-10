# Find and replace transformed text.
export def transform [
	find : string # What to replace.
	transform : closure # Replace item.
	#--no-expand = false
	#--all = false # Replace all occurrences of the pattern.
	#--multiline = false # Multi-line regex mode (implies --regex): ^ and $ match begin and end of line respectively; equivalent to (?m)
	#--regex = false # Match the pattern as a regular expression i nthe input, instead of a substring.
]: [string -> string] {
	let slice = $in
		| split row $find

	let new = $slice
		| drop 1
		| enumerate
		| par-each {|e|
			$e.item + $find
		}

	$new ++ ($slice | last)
	#| str join
}
