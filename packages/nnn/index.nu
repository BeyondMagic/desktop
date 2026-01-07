# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const local = '/usr/local/bin/'
const dir = "/tmp/packages/nnn"
const remote = "https://github.com/jarun/nnn/"
const args = [
	O_NERD=1
]

export def clone []: nothing -> any {
	rm -rf $dir
	
	run-external ...([
		git
		clone
		$remote
		$dir
	])
}

export def build []: nothing -> any {
	cd $dir

	run-external ...([
		make
		...$args
		all
	])
}

export def install []: nothing -> any {
	cd $dir

	run-external ...([
		doas
		make
		install
	])
}

export def uninstall []: nothing -> any {
	cd $dir

	run-external ...([
		doas
		make
		uninstall
	])
}