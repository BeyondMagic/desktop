# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const target = "./terminal-nu"
const local = '/usr/local/bin/terminal-nu'

export def clone []: nothing -> any {}

export def build []: nothing -> any {}

export def install []: nothing -> any {
	run-external ...[
		doas
		cp
		$target
		$local
	]
}

export def uninstall []: nothing -> any {
	run-external ...[
		doas
		rm
		$local
	]
}

export def main []: nothing -> any {
	install
}