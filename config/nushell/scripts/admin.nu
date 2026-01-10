#!/usr/bin/env nu
#
# AN3223 © 2022
# João Farias © 2022-2024 BeyondMagic <beyondmagic@mail.ru>

# Edit a priviliged file with the normal editor.
#
# Every argument will be treated as a file to edit.
#
# This script is SECURIRTY SENSTIVE! Special care has been taken to correctly preserve file attributes. Please exercise CAUTION when modifyin AND using this script.
#
# Dependencies:
#	- diff
export def editor [
	...filepaths : string # File-paths to edit, either absolute or relative.
	--limit-tries : int = 3 # Limit of tries when failed password input.
	--temporary : string = '/tmp/' # Temporary folder.
]: nothing -> nothing {

	use std log

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

	for $filepath in $filepaths {

		mut can_read = true

		let fullpath = $filepath | path expand

		# Test if the file exists AND it is a file.
		if ($fullpath | path type) != 'file' {
			
			# It may be due to permissions, so let's try to
			# read the file anyway with elevated access.
			let exit_code = main {|file| open $file } --args [ $fullpath ]
				| complete
				| get exit_code

			# We set the variable here because if it falls in the if
			# it will throw an error anyway.
			$can_read = false

			if $exit_code != 0 {
				error make {
					msg: "Failed parsing file."
					label: {
						text: "Not a file or does not exist."
						span: (metadata $filepath).span
					}
				}
			}
		}

		# Exit if we can write the file.
		if (test -w $fullpath | complete | get exit_code) == 0 {
			error make {
				msg: "Permission already given."
				label: {
					text: "Is a file you can edit."
					span: (metadata $filepath).span
				}
			}
		}

		let tmp = $temporary + (basename $fullpath)
		cd $temporary

		if $can_read {
			cp $fullpath $tmp
		} else {
			# Copy the file as root to be able to get its content.
			main {|from, to|
				cp $from $to
			} --args [ $fullpath $tmp ]
			| complete

			# Make the file accessible for the user.
			main {|file, user|
				chown -R ($user + ':' + $user) $file
			} --args [
				$tmp
				(whoami)
			]
			| complete
		}

		^$env.EDITOR $tmp

		# Try to read the file
		let is_same = (if $can_read {
			^diff --ignore-trailing-space --brief $fullpath $tmp
		} else {
			main {|a, b|
				^diff --ignore-trailing-space --brief $a $b
			} --args [
				$fullpath
				$tmp
			]
		# When the exit code is zero, it has the same content.
		} | complete | get exit_code) == 0

		if $is_same {

			log warning " File unchanged, exiting..."

		} else {

			mut times = 0
			while $times < $limit_tries {
				$times += 1

				let exit_code = main {|from, to|
						# Good old fashioned way to write data.
						^dd ("if=" + $from) ("of=" + $to)
					} --args [
						$tmp
						$fullpath
					]
					| complete
					| get exit_code

				# Wrong password attempt.
				if $exit_code == 1 {
					
					if $times == $limit_tries {
						log warning $" You failed ($limit_tries) times, the limit, exiting..."
						break
					}
					continue

				# Forced exit.
				} else if $exit_code == -1 {
					log warning " Canceled, exiting..."
					break

				# Successful attemp.
				} else {
					log debug " Done, changes written."
					break
				}
			}
		}
		# NOTE: force non-interactivity here.
		^rm $tmp
		cd -
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
		# The could itself.
		$closure_code
		# Enclose each argument with double quotes.
		# NOTE: may need to escape its double quotes themselves.
		...($args | par-each {|arg| '"' + $arg + '"' })
	] | str join ' '

	# Run the elevated access command.
	^doas nu --commands $command
}
