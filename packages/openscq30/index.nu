# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const local = '/usr/local/bin/'
const name = "OpenSCQ30"
const dir = "/tmp/openscq30"

const gui = {
	name: "openscq30-gui"
	binary: 'target/release/openscq30-gui'
}

const cli = {
	name: "openscq30-cli"
	binary: 'target/release/openscq30'
}

export def clone []: nothing -> any {
	(
		^doas
		rm -rf $dir
	)

	(
		^git
		clone
		--recurse-submodules
		"https://github.com/Oppzippy/OpenSCQ30"
		$dir
	)
}

export def build []: nothing -> any {
	cd $dir

	(
		^cargo
		build
		--package $gui.name
		--release
	)
	(
		^cargo
		build
		--package $cli.name
		--release
	)
}

export def install []: nothing -> any {
	cd $dir

	(
		^doas
		cp $gui.binary
		($local + $gui.name)
	)
	(
		^doas
		cp $cli.binary
		($local + $cli.name)
	)
}

export def uninstall []: nothing -> any {
	(
		^doas
		rm ($local + $gui.name) ($local + $cli.name)
	)
}