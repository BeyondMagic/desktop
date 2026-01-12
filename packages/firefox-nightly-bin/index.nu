# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const name = "firefox-nightly-bin"
const dir = "/tmp/packages/firefox-nightly-bin/"
const remote = [
	"./PKGBUILD"
	"./firefox-nightly.desktop"
	"./policies.json"
]

export def clean []: nothing -> any {
	rm --recursive --force $dir
}

export def clone []: nothing -> any {
	mkdir $dir
	
	cp ...$remote $dir
}

export def build []: nothing -> any {
	cd $dir

	run-external ...([
		makepkg
		-sLf
		--skippgpcheck
	])
}

export def install []: nothing -> any {
	cd $dir

	run-external ...([
		makepkg
		-i
		--skippgpcheck
	])
}

export def uninstall []: nothing -> any {
	cd $dir

	run-external ...([
		doas
		pacman
		-Rn
		$name
	])
}

export def main []: nothing -> any {
	clean
	clone
	build
	install
	clean
}