# João V. Farias © BeyondMagic 2026 <beyondmagic@mail.ru>

const local = '/usr/local/bin/'
const dir = "/tmp/packages/nnn"
const remote = "https://github.com/jarun/nnn/"
const args = [
	O_NERD=1
]

def run [
	--dry # Print commands without executing them.
]: closure -> any {
	if $dry {
		print (view source $in)
		return
	} else {
		do $in
	}
}

export def clone [
	--dry # Print commands without executing them.
]: nothing -> any {
	{ rm -rf $dir } | run --dry=($dry)
	
	{ run-external ...[ git clone $remote $dir ] } | run --dry=($dry)
}

export def build [
	--dry # Print commands without executing them.
]: nothing -> any {
	cd $dir

	{ run-external ...[ make ...$args all ] } | run --dry=($dry)
}

export def install [
	--dry # Print commands without executing them.
]: nothing -> any {
	cd $dir

	{ run-external ...[ doas make install ] } | run --dry=($dry)
}

export def uninstall [
	--dry # Print commands without executing them.
]: nothing -> any {
	cd $dir

	{ run-external ...[ doas make uninstall ] } | run --dry=($dry)
}

export def main [
	--dry # Print commands without executing them.
]: nothing -> any {
	clone --dry=($dry)
	build --dry=($dry)
	install --dry=($dry)
}