# João V. Farias © BeyondMagic 2025 <beyondmagic@mail.ru>

export module service {

	# Install a managed service by label.
	export def install [
		service: string # The label of the service to install.
	]: nothing -> nothing {
		# TODO: Implement installation logic for the given service label.
	}

	# Placeholder: enable autostart for the given service label.
	export def autostart [
		service: string # The label of the service to enable autostarting.
	]: nothing -> nothing {
		# TODO: Implement autostart enabling logic for the given service label.
	}
}

# View information about the system host.
export def host []: nothing -> record {
	sys host
	| merge {
		machine_id: (
			open /etc/machine-id
			| str trim
		)
	}
}

# Validate the current machine against the configured devices.
export def setup []: record<devices: list<record<label: string, machine_id: string>>> -> any {

	let machine_id = host | get machine_id

	let device = $in
		| get devices
		| where { $in.machine_id == $machine_id }
		| first

}

# View information about the system.
# 
# You must use one of the following subcommands. Using this command as-is will only produce this help message.
#
# This command has been extended from the built-in `sys` command, you can read more at: `https://github.com/BeyondMagic/desktop`
export def main []: nothing -> any {
	sys --help
}