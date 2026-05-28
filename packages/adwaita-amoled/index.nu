# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const local = '/usr/share/themes/'
const dir = "/tmp/packages/Adwaita-AMOLED"
const remote = "https://github.com/librerob/Adwaita-AMOLED.git"


export def clone []: nothing -> any {
	rm -rf $dir

	run-external ...[ git clone $remote $dir ]
}

export def build []: nothing -> any {}

export def install []: nothing -> any {
	run-external ...[ doas cp -r $dir $local ]
}

export def uninstall []: nothing -> any {
	let theme = $dir
		| path basename

	let full = $local
		| path join $theme

	run-external ...[ doas rm -r $full ]
}

export def main []: nothing -> any {
	clone
	build
	install
}
