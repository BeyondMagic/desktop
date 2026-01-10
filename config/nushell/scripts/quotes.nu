#!/usr/bin/env nu
#
# BeyondMagic © João Farias 2024 <beyondmagic@mail.ru>

const default_database: list<string> = [
	'~/armazenamento/citações/*'
]

# Add quote to database.
export def add [
	words : list<string> # The words
	--authors : list<string> # Author(s) of the quote.
	--sources : list<string> # Source(s) of the quote.
	--time : datetime # When quote was made.
	--database : string # The database to load from.
]: nothing -> nothing {

	if ($database | describe) == nothing or not ($database | path exists) {
		error make {
			msg: "--database failed parsing."
			label: {
				text: "Empty or path does not exist."
				span: (metadata $database).span
			}
		}
	}

	if ($words | is-empty) {
		error make {
			msg: "Empty quote given."
			label: {
				text: "Is empty."
				span: (metadata $words).span
			}
		}
	}

	let path = $database
		| path expand

	[{
		words: $words
		authors: $authors
		sources: $sources
		dates: {
			added: (date now)
			time: $time
		}
	}] ++ (open $path) | save --force $path
}

# Initialise database.
export def setup [
	database: list<string> = $default_database # The database(s) to load from.
]: nothing -> nothing {
	$database | par-each {|path|
		[] | save $path
	}
	null
}

# List all quotes of databases.
export def main [
	database: list<string> = $default_database # The database(s) to load from.
	--sort = true # Sort quotes by date added.
]: nothing -> list<any> {
	let files = $database
		| par-each {|item|
			glob $item
		}
		| flatten

	let data = open ...$files

	if $sort {
		$data
			| update dates.added {|context|
				$context.dates.added
					| into datetime
			}
			| sort-by dates
	} else {
		$data
	}
}
