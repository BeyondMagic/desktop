# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const local_share = '/usr/local/share/dakanji'
const local_bin = '/usr/local/bin/dakanji'
const dir = "/tmp/packages/dakanji"
const zip = {
	outer: "dakanji.zip"
	inner: "DaKanji_3.5.2+131_ubuntu_24_04.zip"
}
const remote = "https://github.com/CaptainDario/DaKanji/releases/download/v3.5.2/DaKanji_3.5.2+131_ubuntu_24_04.zip"
const target = "./build/linux/x64/release/bundle/"
const target_bin = "./DaKanji"
const icon = "./icon.png"
const local_icon = "/usr/share/icons/dakanji.png"
const desktop = "./DaKanji.desktop"
const local_desktop = "/usr/share/applications/DaKanji.desktop"

# make it possible to run --dry-run
# def run-external

export def clone []: nothing -> any {
	rm -rf $dir

	mkdir $dir

	cp $icon $desktop $dir

	cd $dir
	
	http get --raw $remote | save $zip.outer
}

export def build []: nothing -> any {
	cd $dir

	run-external ...[
		unzip
		$zip.outer
	]

	run-external ...[
		unzip
		$zip.inner
	]
}

export def install []: nothing -> any {
	cd $dir

	run-external ...[
		doas
		cp
		-rf
		$target
		$local_share
	]

	run-external ...[
		doas
		ln
		--symbolic
		--force
		($local_share | path join $target_bin)
		$local_bin
	]

	run-external ...[
		doas
		cp
		$icon
		$local_icon
	]

	run-external ...[
		doas
		cp
		$desktop
		$local_desktop
	]
}

export def uninstall []: nothing -> any {
	run-external ...[
		doas
		rm
		$local_bin
		($local_share | path join $target_bin)
	]
}

export def main []: nothing -> any {
	clone
	build
	install
}