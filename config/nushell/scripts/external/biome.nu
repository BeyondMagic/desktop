#!/usr/bin/env nu
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2026

# Format file with biome, using biome format command. Supported formats: json, yaml, toml).
export def format [
	file: string # Format file for biome (e.g. "json", "yaml", "toml").
	--max-size: int = 100000000 # Maximum file size to process (default: 100MB).
]: nothing -> nothing {

	let max_size = $max_size | into string

	run-external ...[
		biome
		format
		('--files-max-size=' + $max_size)
		--write
		$file
	]
}