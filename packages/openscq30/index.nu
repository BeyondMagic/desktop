# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const local = '/usr/local/bin/'
const name = "OpenSCQ30"
const dir = "/tmp/openscq30"
const remote = "https://github.com/Oppzippy/OpenSCQ30"

const gui = {
	name: "openscq30-gui"
	binary: 'target/release/openscq30-gui'
}

const cli = {
	name: "openscq30-cli"
	binary: 'target/release/openscq30'
}

export def clone []: nothing -> any {
	run-external ...[
		doas
		rm
		-rf
		$dir
	]

	run-external ...[
		git
		clone
		--recurse-submodules
		$remote
		$dir
	]
}

export def build []: nothing -> any {
	cd $dir

	run-external ...[
		cargo
		build
		--package $gui.name
		--release
	]
	run-external ...[
		cargo
		build
		--package $cli.name
		--release
	]
}

export def install []: nothing -> any {
	cd $dir

	run-external ...[
		doas
		cp
		$cli.binary
		$gui.binary
		($local + $cli.name)
	]
}

export def uninstall []: nothing -> any {
	run-external ...[
		doas
		rm
		($local + $gui.name)
		($local + $cli.name)
	]
}

export def main []: nothing -> any {
	clone
	build
	install
}