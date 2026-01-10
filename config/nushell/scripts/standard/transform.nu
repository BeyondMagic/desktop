# ...
export def main [
	transforms: list<closure> # Blocks to apply to each input item.
]: list<any> -> list<any> {
	let values = $in
	let input_len = $values | length
	let block_len = $transforms | length

	if $input_len != $block_len {
		error make {
			msg: "Input length differs from number of transforms."
			label: {
				text: "Provide the same number of transforms as input items."
				span: (metadata $transforms).span
			}
		}
	}

	$values
	| enumerate
	| each {|row|
		let block = $transforms | get $row.index
		$row.item | do $block
	}
}