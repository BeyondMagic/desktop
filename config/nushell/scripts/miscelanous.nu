# BeyondMagic © João Farias 2024 <beyondmagic@mail.ru>

# Copies the actual path for clipboard.
export def cpdir [
	file: string = './' # Path to copy.
]: nothing -> nothing {
	$file
	| path expand
	| ^wl-copy
}

# Function to take last clipboard into an image.
export def to-image [
	...name: string # File name.
	--type : string = 'png' # Type extension file.
	--force # Force save.
]: nothing -> nothing {
	let file_name = ($name | str join ' ') + '.' + $type

	^wl-paste
	| save --force=$force $file_name
}

# Return all magnet links from HTML page.
export def get-magnets [
]: string -> list<string> {
	$in
	| parse --regex 'href="magnet:(.*?)"'
	| get capture0
	| par-each --keep-order {
		'magnet:' + $in
	}
}

# From HTML page of `comandofilmes`, parse content.
export def parse-page [
]: string -> any {
	$in
	| lines
	| find --multiline --regex ' href="magnet:.*"'
	| parse --regex `<strong>(.*?):</strong>\s(.*)`
	| par-each --keep-order {|item|
		let titles = $item.capture1
			| parse --regex '">(.*?)<'
			| rename quality

		let links = $item.capture1
			| parse --regex ' href="(.*?)"'
			| rename magnets

		{
			episode: $item.capture0
			links: (
				$titles | merge $links
			)
		}
	}
}
