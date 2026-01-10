# João V. Farias © BeyondMagic 2025-2026 <beyondmagic@mail.ru>

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

export module config {

	# Link configuration files for the current machine based on its machine_id.
	export def link []: record<devices: list<record<label: string, machine_id: string>>, source: string, target: string> -> nothing {
		let machine_id = sys host | get machine_id
		let device = $in.devices | where { $in.machine_id == $machine_id }
	
		if ($device | length) != 1 {
			error make {
				msg: "Could not find a unique device configuration for this machine_id"
				code: "sys::config::link::device_not_found"
				labels: {
					text: $"machine_id: ($machine_id)"
					span: (metadata $device).span
				}
				help: "Ensure that the configuration file has a unique entry for this machine_id."
			}
		}
	
		let device_label = $device | first | get label
	
		let source = $in.source
		| str replace --all `{device}` $device_label
	
		let target = $in.target
		| path expand
	
		if ($target | str ends-with `/`) {
			mkdir $target
		} else {
			let parent = $target | path dirname
			mkdir $parent
		}

		let sources = glob $source
		if ($sources | length) == 0 {
			error make {
				msg: "No configuration files found to link."
				code: "sys::config::link::sources_not_found"
				labels: {
					text: $"source pattern: ($source)"
					span: (metadata $in.source).span
				}
				help: "Ensure that the source pattern matches existing files."
			}
		}

		let ln_args = [
			"ln"
			"--verbose"
			"--no-dereference"
			"--force"
			"--relative"
			"--symbolic"
		]
	
		$sources | each {
			run-external ...$ln_args $in $target
		}
	}
	
	# View/list the current configuration.
	export def main []: nothing -> any {
		# TODO: Implement logic to retrieve and return the current configuration.
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