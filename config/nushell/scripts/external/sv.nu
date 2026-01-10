# João V. Farias © BeyondMagic <beyondmagic@mail.ru> 2024

# Check for the service(s) to be in the state that's been requested.
#
# Wait up to 7 seconds for the service(s) to reach the requested state, then report the status or timeout.
# If the requested state of the service(s) is/are up, and the script ./check exists in the service(s) directory,
# sv runs this script to check whether the service is up and running;
# it's considered to be up if ./check exits with 0.
export def check [
	...path: string # Path of the service(s).
]: nothing -> list<any> {
	let services = $path
		| par-each --keep-order {|name|
			let paths = glob $name
			if ($paths | is-empty) {
				[ $name ]
			} else {
				$paths
			}
		}
		| flatten

	main [
		'check'
		...$services
	]
	| lines
	| str replace --all --regex `(\d+s)|,` `: $1`
	| str replace --all --regex ` normally| want|\(pid |\)` ``
	| split column `: ` 'status' 'running' 'service' 'pid' 'uptime' 'normally' 'want'
	| par-each --keep-order {
		$in
		| update 'running' {
			$in == 'run'
		}
		| update 'pid' {
			if ($in | is-not-empty) {
				$in | into int
			} else {
				null
			}
		}
		| update 'uptime' {
			if $in == '0s' {
				null
			} else {
				(date now) - ($in + 'ec' | into duration)
			}
		}
		| default null 'normally'
		| default null 'want'
	} | sort-by 'running'
}

# Control and manage services monitored by runsv.
# See sv manual(1).
#
# The sv program reports the current status and controls the state of services
# monitored by the runsv(8) supervisor. Itored by the runsv(8) supervisor.s.
def main [
	arguments: list<string> # Arguments to pass for external command.
]: nothing -> any {
	^sv ...$arguments
}
