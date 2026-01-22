# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const local = '/usr/local/bin/'
const dir = "/tmp/packages/nnn"
const remote = "https://github.com/jarun/nnn/"
const nu_plugin = "./misc/quitcd/quitcd.nu"
const args = [
	O_NERD=1
]


export def clone []: nothing -> any {
	rm -rf $dir
	
	run-external ...[ git clone $remote $dir ]
}

export def build []: nothing -> any {
	cd $dir

	run-external ...[ make ...$args all ]
}

export def install []: nothing -> any {
	cd $dir

	let lib_dir = $env.NU_LIB_DIRS | last

	mkdir $lib_dir
	cp $nu_plugin $lib_dir
	run-external ...[ doas make install ]
}

export def uninstall []: nothing -> any {
	cd $dir

	let lib_dir = $env.NU_LIB_DIRS | last
	let plugin_file = $nu_plugin | path basename

	rm ($lib_dir | path join $plugin_file)
	run-external ...[ doas make uninstall ]
}

export def main []: nothing -> any {
	clone
	build
	install
}