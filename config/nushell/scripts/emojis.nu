#!/usr/bin/env nu
#
# BeyondMagic © João Farias 2024 <beyondmagic@mail.ru>

const default_database = [
	"~/storage/kaomojis.json"
	"~/storage/emojis.json"
]

# List all emoji and/or kaomojis of database.
export def main [
	database: list<string> = $default_database # List of paths of database
]: nothing -> list<table<hieroglyph: string, tags: list<string>>> {
	$default_database | par-each {|path|
		open (glob $path | first)
	} | flatten | flatten
}
