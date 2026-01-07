# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const name = "yay-bin"
const dir = "/tmp/packages/yay"
const remote = "https://aur.archlinux.org/yay-bin.git"

export def clone []: nothing -> any {
	run-external ...([
		doas
		rm
		-rf
		$dir
	])

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
	
	run-external ...([
		makepkg
		-si
		--noconfirm
	])
}
export def install []: nothing -> any {}

export def uninstall []: nothing -> any {
	run-external ...([
		doas
		pacman
		-Rn
		$name
	])
}