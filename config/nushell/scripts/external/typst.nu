# Install packages in system.
export def fonts []: nothing -> list<string> {
	main [
		'fonts'
	] | lines
}

# The command itself for the package manager.
# See typst manual(1).
#
# typst is a cli compiler for the language-parser typst.
def main [
	arguments: list<string> # Arguments to pass for it.
]: nothing -> any {
	^typst ...$arguments
}
