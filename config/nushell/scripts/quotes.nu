#!/usr/bin/env nu
#
# BeyondMagic © João Farias 2024-2026 <beyondmagic@mail.ru>

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

	let path = $database
		| path expand

	if not ($path | path exists) {
		error make {
			msg: "--database failed parsing."
			code: "quotes::add::invalid-database"
			labels: {
				text: "Empty or path does not exist."
				span: (metadata $database).span
			}
			help: "Provide a valid path to a quotes database."
		}
	}

	if ($words | is-empty) {
		error make {
			msg: "Empty quote given."
			code: "quotes::add::empty-quote"
			labels: {
				text: "Is empty."
				span: (metadata $words).span
			}
			help: "Provide at least one word for the quote."
		}
	}

	# Backup existing database since the program may crash/closed while writing later.
	let content = open $path
	let backup_path = $path + ".bak"

	# If there's a backup already, warns the user.
	if ($backup_path | path exists) {
		error make {
			msg: "Backup file already exists, something went wrong last time."
			code: "quotes::add::backup-exists"
			labels: {
				text: "Backup path: $backup_path"
				span: (metadata $path).span
			}
			help: "Remove/check the existing backup file before adding a new quote."
		}
	}

	$content | to json | save $backup_path

	# If disk is busy, it may take a few seconds to write.
	[{
		words: $words
		authors: $authors
		sources: $sources
		dates: {
			added: (date now)
			time: $time
		}
	}] ++ $content | save --force $path

	rm $backup_path
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
