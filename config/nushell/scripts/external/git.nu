#!/usr/bin/env nu
#
# sgasse © 2023
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2024
#
# Custom command to conveniently edit commits in the history.
#
# Use with:
# `use <repo_root>/git/git_edit.nu`
#
# `git edit` starts an interactive rebase to edit a commit in the history, which
# can be selected from a complection list. An example completion list may look
# like this:
#
# >| git edit
# 2024d52  upgrade to nu 0.77 (#413)
# 10bde06  Fix since last release script (#412)
# 18deb3d  Add `nu-cmd-lang` to `nu_release.nu` (#411)
# e95f609  Updated conda script to default to base if no arg given (#409)
# 34235ef  Replace deprecated `str collect` command (#410)
# 06dd125  Revert "conda activate base if env_name not given (#400)" (#408)
# ...

# Helper command to get commit of this branch only list to edit
def "nu-complete git commits" [] {
	main [ log --pretty="%h %s" ]
	| lines
	| parse "{value} {description}"
}

# Edit a commit by selecting it as only commit to edit in an interactive rebase
# run non-interactively.
export def edit [
    commit: string@"nu-complete git commits" # Commit-hashed code to edit.
]: nothing -> nothing {
	# We use `sed` to replace `pick` with `edit`.
	# `0,/pick/` restricts the sustitution to the range from the beginning until
	# the first occurence of `pick`.
	GIT_SEQUENCE_EDITOR="sed -i -e '0,/pick/{s/pick/edit/}'" main [ rebase -i $"($commit)^1" ]
}

# Root folder of the repository.
export def root []: nothing -> string {
	(main [ rev-parse --show-cdup ]
	| path expand
	) + '/'
}

# Parse text of strings of files as paths.
def parse-files [base?: string]: string -> list<string> {
	let before = if ($base | is-empty) {
		root
	} else {
		$base
	}

	$in
	| lines
	| par-each {|path|
		let full = $before | path join $path
		if ($full | path type | is-not-empty) {
			ls --directory $full
			| first
		} else {
			{
				name: $full
				type: 'deleted'
				size: -1B
				modified: (date now)
			}
		}
	}
}

# Realpath fix.
def realpath []: string -> string {
	^realpath -s --relative-to='./' $in
}

# List untracked files.
export def 'list untracked' [
	base?: string # Root folder to find changes within.
]: nothing -> list<string> {
	let before = if ($base | is-empty) {
		root
	} else {
		$base
	}

	cd $before

	let result = main [ -c core.quotepath=false ls-files --others --exclude-standard ]
		| parse-files $base

	cd -

	$result
	| update name { realpath }
}

# See history changes of a path.
export def history [
	path: string # path to see history of.
]: nothing -> table<id: string, description: string> {
	main [
		log
		"--pretty=%h %s"
		$path
	]
	| lines
	| parse "{id} {description}"
	| reverse
}

# See changes made in a path up to a commit (HEAD by default).
export def compare [
	path: string # Path to compare.
	--from: string # Commit to compare from.
	--to: string # Commit to compare to.
]: nothing -> any {

	mut args = [
		diff
		--color=always
		$path
	]

	if (($from | is-not-empty) and ($to | is-empty)) or (($to | is-empty) and ($from | is-not-empty)) {
		error make {
			msg: "Invalid arguments."
			label: {
				text: "You have to specify both `--from` and `--to` or none of them."
				span: (metadata $from).span
			}
		}
	}

	let from = if ($from | is-not-empty) {
		$args = $args
		| insert 1 $from
		| insert 2 $to
	}

	main $args
}

# List files with changes.
export def diff [
	base?: string # Root folder to find changes within.
	--untracked = true # List files not tracked by git.
	--cached = true # List also staged files.
]: nothing -> list<string> {

	let content_git = if ($base | is-empty) {
		main [ '-c' 'core.quotepath=false' 'diff' '--name-only' ]
	} else {
		main [ '-c' 'core.quotepath=false' 'diff' '--name-only' $base ]
	}

	mut result = $content_git
		| parse-files
		| default true 'tracked'
		| default false 'staged'
		| update name { realpath }
	
	if $untracked {
		$result = $result ++ (
			list untracked $base
			| default false tracked
			| default false 'staged'
		)
	}

	if $cached {
		$result = $result ++ (
			main [ 'diff' '--name-only' '--cached' ]
			| parse-files
			| default true 'tracked'
			| default true 'staged'
			| update 'name' { realpath }
		)
	}

	$result
	| sort-by 'staged' 'tracked' 'modified'
}

# Add changes to the last commit and/or update subject and message manually, keep the datetime if not specified.
export def `commit amend` [
	--edit # Do not edit the commit subject and message.
	--datetime: datetime # Date and time of the commit.
]: nothing -> any {
	mut args = [
		'commit'
		'--amend'
	]

	if not $edit {
		$args = $args ++ [ "--no-edit" ]
	}

	let datetime = if ($datetime | is-not-empty) {
		$env.LC_ALL = 'C'
		$env.GIT_COMMITTER_DATE = $datetime
		$env.GIT_AUTHOR_DATE = $datetime
		$datetime
	} else {
		let last_commit_datetime = main [
			log -1 --format='%cd'
		]
		$env.LC_ALL = 'C'
		$env.GIT_COMMITTER_DATE = $last_commit_datetime
		$env.GIT_AUTHOR_DATE = $last_commit_datetime
		$last_commit_datetime
	}

	$args = $args ++ [ '--date' $datetime ]

	main $args
}

# Commit the changes.
export def commit [
	title?: string # Title of the commit.
	message?: string # Message of the commit.
	--datetime: datetime # Date and time of the commit.
	--feat: string # New feature for the user, not a new feature for build script.
	--fix: string # Bug fix for the user, not a fix to a build script.
	--docs: string # Changes to the documentation.
	--style: string # Formatting, missing semi colons, etc; no production code change.
	--refactor: string # Refactoring production code, eg. renaming a variable.
	--test: string # Adding missing tests, refactoring tests; no production code change.
	--chore: string # Updating grunt tasks etc; no production code change.
	--build: string # Changes to the build script.
	--ci: string # Changes to Continuous Integration files and scripts.
	--perf: string # Code change that improves performance.
	--revert: string # Reverts previous commit(s).
	--breaking-changes: list<string> # Breaking changes.
	--co-authors: list<record<name: string, email: string>> # Co-authors of this commit.
	--closes: list<string> # Link issues and pull requests of the repository.
	--refs: list<string> # Link commits (useful for reverting).
]: nothing -> any {

	let semantics = [
		['type', 'value'];
		[ 'feat' $feat ]
		[ 'fix' $fix ]
		[ 'docs' $docs ]
		[ 'style' $style ]
		[ 'refactor' $refactor ]
		[ 'test' $test ]
		[ 'chore' $chore ]
		[ 'build' $build ]
		[ 'ci' $ci ]
		[ 'perf' $perf ]
		[ 'revert' $revert ]
	] | where { $in.value | is-not-empty }

	if ($semantics | length) > 1 {
		error make {
			msg: "Could not parse multiple semantic types."
			label: {
				text: "More than one type of commit semantic was used. Only one is allowed."
				span: (metadata $feat).span
			}
		}
	}

	# Has to take the metadata before it's assigned again.
	let title_span = (metadata $title).span

	mut title = $title
	mut message = if ($message | is-empty) {
		""
	} else {
		$message
	}

	if ($co_authors | is-not-empty) {
		let co_authors = $co_authors
			| each {
				'Co-authored-by: ' + $in.name + ' <' + $in.email + '>'
			} | str join "\n"

		$message = if ($message | is-empty) {
			$co_authors
		} else {
			$co_authors + "\n\n" + $message
		}
	}

	if ($closes | is-not-empty) {
		let closes = $closes
			| each { 'Closes ' + $in + '.' }
			| str join "\n"

		$message = if ($message | is-empty) {
			$closes
		} else {
			$message + "\n\n" + $closes
		}
	}

	if ($refs | is-not-empty) {
		let refs = 'Refs: ' + ($refs | str join ', ') + '.'

		$message = if ($message | is-empty) {
			$refs
		} else {
			$message + "\n\n" + $refs
		}
	}

	mut breaking_symbol = ''

	if ($breaking_changes | is-not-empty) {

		# The exclamation to add before the semantic type.
		$breaking_symbol = '!'

		let breaking_changes = $breaking_changes
			| each { 'BREAKING CHANGE: ' + $in } | str join "\n"

		$message = if ($message | is-empty) {
			$breaking_changes
		} else {
			$message + "\n\n" + $breaking_changes
		}
	}

	if ($semantics | is-not-empty) {

		# It makes no sense to not have a title, but a semantic type of commit chosen.
		if ($title | is-empty) {
			error make {
				msg: "Could not parse semantic and title."
				label: {
					text: "Empty title, but semantic type of commit specified."
					span: $title_span
				}
			}
		}

		# Format the title and semantic type of commit.
		let scope = $semantics | first
		$title = $scope.type + '(' + $scope.value + ')' + $breaking_symbol + ': ' + $title
	}

	mut args = [ commit -S ]

	if ($datetime | is-not-empty) {
		$env.LC_ALL = 'C'
		$env.GIT_COMMITTER_DATE = $datetime
		$env.GIT_AUTHOR_DATE = $datetime
		$args = $args ++ [ '--date' $datetime ]
	}

	if ($title | is-not-empty) {
		$args = $args ++ [ -m $title ]

		if ($message | is-not-empty) {
			$args = $args ++ [ -m $message ]
		}
	}

	main $args
}

# See information of commits.
export def log []: nothing -> any {
	main [ 'log' '--graph' '--reflog' ]
}

# Restore specified paths in the working tree with some contents from a restore source.
export def unstage [
	...paths: string # Paths to restore.
	--patch (-p) # Interactively select hunks in the difference between the restore source and the restore location.
]: nothing -> any {
	let patch = if $patch {
		'--patch'
	}
	
	main [ 'restore' '--staged' $patch ...$paths ]
}

# The command itself for the package manager.
# See git manual(1).
#
# Git is a fast, scalable, distributed revision control
# system with an unusually rich command set that provides
# both high-level operations and full access to internals.
def main [
	arguments: list<any> # Arguments to pass for it.
]: nothing -> any {
	^git ...$arguments
}
