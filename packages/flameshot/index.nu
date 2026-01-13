# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const name = "flameshot"
const local = '/usr/local/bin/'
const dir = "/tmp/packages/flameshot"
const remote = "https://github.com/flameshot-org/flameshot"
const flags = [
	-DUSE_WAYLAND_GRIM=true
]

export def clone []: nothing -> any {
	rm -rf $dir
	
	run-external ...([
		git
		clone
		--recurse-submodules
		$remote
		$dir
	])
}

export def build []: nothing -> any {
	cd $dir

	mkdir build
	cd build
	run-external ...[
		cmake
		...$flags
		'../'
	]
	run-external ...[
		make
	]
}

export def install []: nothing -> any {
	cd $dir

	run-external ...([
		doas
		cp
		('./build/src/' + $name)
		($local + $name)
	])
}

export def uninstall []: nothing -> any {
	run-external ...([
		doas
		rm
		($local + $name)
	])
}

export def main []: nothing -> any {
	clone
	build
	install
}