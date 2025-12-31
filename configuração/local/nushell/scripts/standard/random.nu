# João Farias © BeyondMagic 2024 <beyondmagic@mail.ru>

# Return a random item of the given list.
export def item []: list<any> -> any {
	let piped = $in
	if ($piped | is-empty) {
		error make {
			msg: "Failed to find data."
			code: "random::item::no_data"
			label: {
				text: "Not given any data."
				span: (metadata $piped).span
			}
			help: "Provide a non-empty list of items to select from."
		}
	}
	$piped
	| get (
		random int 0..(
			($piped | length) - 1
		)
	)
}
