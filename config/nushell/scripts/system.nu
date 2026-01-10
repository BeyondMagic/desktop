# System management commands for Nushell.
# 
# João Farias © 2025 BeyondMagic <beyondmagic@mail.ru>

use admin.nu

# Shutdown the system.
export def shutdown []: nothing -> nothing {
	admin { ^poweroff }
}

# Suspend the machine to disk.
export def hibernate []: nothing -> nothing {
	# ^loginctl hibernate
	^doas zzz
}

# Suspend the system to memory.
export def suspend []: nothing -> nothing {
	^loginctl suspend
}

# Restart the system.
export def restart []: nothing -> nothing {
	admin { ^shutdown -r now }
}

# List all fonts.
export def fonts []: nothing -> table<path: string font: string> {
	^fc-list
	| lines
	| par-each {|line|
		let data = $line
			| split row --number 2 ': '

		{
			path: $data.0
			font: $data.1
		}
	}
}
