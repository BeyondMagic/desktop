# Package manager for Python packages.
# See pip manual(1).
#
# pip is the PyPA recommended package manager for Python packages.
#
# Uses the environment variable PYTHON_VENV as the root folder for an environment variable.
# See the manual to create one. Tip: PYTHON_VENV folder should have a `bin` folder.
export def pip [
	arguments: list<string> # Arguments to pass for python external command.
]: string -> any {
	# Send input data.
	$in
	| ^($env.VIRTUAL_ENV | path join 'bin/pip') ...$arguments
}

# An interpreted, interactive, object-oriented programming language.
# See python manual(1).
#
# Python is an interpreted, interactive, object-oriented programming language that
# combines remarkable power with very clear syntax. For an introduction to programming
# in Python, see the Python Tutorial. The Python Library Reference documents built-in
# and standard types, constants, functions and modules. Finally, the Python Reference
# Manual describes the syntax and semantics of the core language in (perhaps too) much
# detail.
# (These documents may be located via the INTERNET RESOURCES below;
# they may be installed on your system as well.)
export def --env main [
	arguments: list<string> # Arguments to pass for python external command.
]: string -> any {
	if ($in | is-not-empty) {
		return ($in | ^($env.VIRTUAL_ENV | path join 'bin/python') ...$arguments)
	}

	# Send input data.
	^($env.VIRTUAL_ENV | path join 'bin/python') ...$arguments
}
