# To get the filename of all binaries found in the environment variable PATH.
def "nu-complete exec" []: string -> list<string> {
	$env.PATH
	| par-each {
		if ($in | path type) == 'dir' {
			ls --short-names $in
		}
	}
	| flatten
	| get name
	| sort
}

# Won't redefine `exec`,
# just add signature for it's parameters.
export extern main [
    executable: string@"nu-complete exec" # List of executable files.
    ...args: string # Any extra arguments for the external command.
]
