#!/usr/bin/env -S nu --stdin

def main []: string -> nothing {
	let image = $in

	let to = [
			'extensões/jpg'
			'extensões/png'
			'arte/extensões/jpg'
			'arte/extensões/png'
			'arte/poemas'
			'arte/gl'
			'arte/bandeiras'
			'arte/design'
			'fotos'
			'perfil/quadrado'
			'perfil/thumbnail'
			'perfil/alto'
		]
		| str join "\n"
		| fuzzel --dmenu

	if ($to | is-empty) {
		exit 1
	}
	
	let base = '/home/dream/armazenamento/imagens/'

	mv $image ($base + $to)
}
