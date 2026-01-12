# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const dir = "/tmp/packages/advcpmv"
const remote = "https://raw.githubusercontent.com/jarun/advcpmv/master/install.sh"
const local = "/usr/local/bin/"
const targets = [
	{
		name: "advmv",
		bin: "mvg"
	}
	{
		name: "advcp",
		bin: "cpg"
	}
]

export def clone []: nothing -> any {
	run-external ...[
		doas
		rm
		-rf
		$dir
	]
	
	mkdir $dir

	cd $dir

	http get --raw $remote | save 'install.sh'
}

export def build []: nothing -> any {
	cd $dir

	run-external ...[
		sh
		install.sh
	]
}

export def install []: nothing -> any {
	cd $dir

	$targets | each {
		run-external ...[
			doas
			cp
			$in.name
			($local + $in.bin)
		]
	}
	null
}

export def uninstall []: nothing -> any {
	$targets | each {
		run-external ...[
			doas
			rm
			($local + $in.bin)
		]
	}
	null
}

export def main []: nothing -> any {
	clone
	build
	install
}