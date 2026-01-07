# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const name = "hypr-minimize"
const local = '/usr/local/bin/'
const dir = "/tmp/packages/hypr-minimize"
const remote = "https://github.com/BeyondMagic/thunderbird-minimize-hyprland/"

export def clone []: nothing -> any {
	rm -rf $dir
	
	run-external ...([
		git
		clone
		$remote
		$dir
	])
}

export def build []: nothing -> any {}

export def install []: nothing -> any {
	cd $dir

	run-external ...([
		doas
		cp
		$name
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