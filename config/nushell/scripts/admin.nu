#!/usr/bin/env nu
#
# AN3223 © 2022
# João Farias © 2022-2024 BeyondMagic <beyondmagic@mail.ru>

# Run doas with the given arguments.
export def doas [
	args : list<string> # Arguments to pass to doas.
]: nothing -> nothing {
	run-external ...[
		doas
		...$args
	]
}

# Edit a privileged file with the normal editor.
#
# Every argument will be treated as a file to edit.
#
# This script is SECURITY SENSITIVE! Special care has been taken to correctly preserve file attributes. Please exercise CAUTION when modifying AND using this script.
export def editor [
	...filepaths : string # File-paths to edit, either absolute or relative.
	--temporary : string = '/tmp/' # Temporary folder.
]: nothing -> nothing {

	use std/log

	# Exit if environment variable EDITOR is not set.
	if not ('EDITOR' in $env) or $env.EDITOR == '' {
		error make {
			msg: "Environment failed parsing."
			label: {
				text: "$env.EDITOR is not set."
				span: (metadata $env).span
			}
		}
	}

	let tmp_base = ($temporary | path expand)

	for $filepath in $filepaths {
		let fullpath = ($filepath | path expand)

		# Exit if we can already write the file.
		if (^test -w $fullpath | complete | get exit_code) == 0 {
			error make {
				msg: "Permission already given."
				label: {
					text: "Is a file you can edit."
					span: (metadata $filepath).span
				}
			}
		}

		let can_read = ((^test -r $fullpath | complete | get exit_code) == 0)
		if $can_read and ($fullpath | path type) != 'file' {
			error make {
				msg: "Failed parsing file."
				label: {
					text: "Not a file or does not exist."
					span: (metadata $filepath).span
				}
			}
		}

		let tmp_dir = (^mktemp --directory $"--tmpdir=($tmp_base)" admin-editor.XXXXXX | str trim)
		let tmp = ($tmp_dir | path join ($fullpath | path basename))
		touch $tmp
		^chmod 600 $tmp

		if $can_read {
			^dd $"if=($fullpath)" $"of=($tmp)" status=none
		} else {
			let copy_res = (main {|src, dst|
				if ($src | path type) != 'file' {
					exit 2
				}
				^dd $"if=($src)" $"of=($dst)" status=none
			} --args [ $fullpath $tmp ] | complete)

			if $copy_res.exit_code != 0 {
				^rm -rf $tmp_dir
				if $copy_res.exit_code == 2 {
					error make {
						msg: "Failed parsing file."
						label: {
							text: "Not a file or does not exist."
							span: (metadata $filepath).span
						}
					}
				}
				error make {
					msg: "Failed reading file."
					label: {
						text: "Could not read file with elevated privileges."
						span: (metadata $filepath).span
					}
				}
			}
		}

		let before_hash = (open --raw $tmp | hash sha256)
		^$env.EDITOR $tmp
		let after_hash = (open --raw $tmp | hash sha256)

		if $before_hash == $after_hash {
			log warning " File unchanged, exiting..."
			^rm -rf $tmp_dir
		} else {
			let write_res = (main {|from, to|
				^dd $"if=($from)" $"of=($to)" status=none
			} --args [ $tmp $fullpath ] | complete)

			if $write_res.exit_code == 0 {
				log debug " Done, changes written."
				^rm -rf $tmp_dir
			} else {
				log warning $" Failed to write changes; edited copy preserved at ($tmp)"
			}
		}
	}
}

# Run command with elevated priviliges.
#
# Will run as the default priviged user for doas (root).
#
# Dependencies:
# - doas
export def main [
	code : closure # Code to run
	--args : list<string> = [] # The arguments to be passed to the closure.
]: nothing -> nothing {
	let closure_code = view source $code

	let command = [
		# To run the closure.
		do
		# The code itself.
		$closure_code
		# Safely encode each argument as a NUON literal while preserving order.
		...($args | each { $in | to nuon })
	] | str join ' '

	# Run the elevated access command.
	doas [
		nu
		--commands
		$command
	]
}
