#!/usr/bin/env nu
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2024-2025

# Spawn closure command(s) in the background and return PID.
#
# Dependencies:
#	sh
#	nohup
#
# Will launch into default POSIX shell first then redirect all output (stderr and stdout) to $log while self-executing into nushell nohup'd.
export def main [
	command: any # The commands to run.
	--stdout: string = '/dev/null' # Redirect stdout to file.
	--stderr: string = '/dev/null' # Redirect stderr to file.
]: nothing -> any {
	let type = $command
		| describe

	let source_code = if $type == 'string' {
		$command
			| str trim
	} else if $type == 'closure' {
		view source $command
			| str replace --all `"` `\"`
			| str substring 2..-2
		# ^ Escape double quotes for POSIX shell.
		# ^ Remove the `{ ` and ` }` from source of command.
	} else {
		error make {
			msg: "Not supported"
			label: {
				text: $"'($type)' type is not supported \(yet\)."
				span: (metadata $command).span
			}
		}
	}
	
	# Spawner of the process.
	let command = [
		# Fork the spawner.
		exec nohup
		# Use chosen shell to execute the given command.
		nu --commands
		# Escape the command using double quotes.
		('"' + $source_code + '"')
		# Send standard output and error streams to chosen files.
		# Uses POSIX syntax.
		'1>' $stdout '2>' $stderr
		# Print the PID.
		& echo '$!'
	]
	| str join ' '

	# Execute the command in the background shell.
	^sh -c -- $command
	| into int
	# Return the PID of the executed command.
}
