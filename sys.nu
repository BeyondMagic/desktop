# João V. Farias © BeyondMagic 2025-2026 <beyondmagic@mail.ru>

# A helper function to simulate command execution in dry-run mode.
def dry-run []: list<string> -> nothing {
	print $in
}

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

	def make_dir [
		--target: string # The target directory to create.
		--root # Whether to create the directory with elevated privileges.
		--dry_run # If specified, the command will only simulate the creation without making
	]: nothing -> nothing {

		if not $root {
			if $dry_run {
				[ 'mkdir' $target ] | dry-run
			} else {
				mkdir $target
			}
			return
		}

		try {
			let args = [
 				"doas"
 				"mkdir"
 				"--parents"
 				$target
 			]

			if $dry_run {
				$args | dry-run
				return
			}

			run-external ...$args
 		} catch {|err|
 			error make {
 				msg: $"Failed to create directory '($target)' with elevated privileges."
 				code: "sys::config::link::mkdir_failed"
 				labels: {
 					text: (if ('msg' in $err) {
 						$"Underlying error: ($err.msg)"
 					} else {
 						"Failed to execute 'doas mkdir --parents' for the target directory."
 					})
 					span: (metadata $in.target).span
 				}
 				help: "Check that 'doas' is installed and configured, and that you have permission to create the target directory."
 			}
 		}
	}

	# Link configuration files for the current machine based on its machine_id.
	#
	# Dependencies:
	# - doas (if `--root` is specified)
	export def link [
		--device-label: string # The label of the device/machine to link configuration for.
		--dry-run # If specified, the command will only simulate the linking without making any changes.
	]: record<devices: list<record<label: string, machine_id: string>>, source: string, target: string, root: bool, exclude: list<string>> -> nothing {

		if ($device_label | is-empty) {
			error make {
				msg: "Device label must be specified."
				code: "sys::config::link::device_label_missing"
				labels: {
					text: "The --device-label argument is required."
					span: (metadata $in).span
				}
				help: "Provide a valid device label corresponding to your machine."
			}
		}

		let source = $in.source
		| str replace --all `{device}` $device_label
	
		let target = $in.target
		| path expand --no-symlink

		let is_target_dir = $target | str ends-with `/`
	
		let dir_target = if $is_target_dir {
			$target
		} else {
			$target | path dirname
		}

		make_dir --target=($dir_target) --root=($in.root) --dry_run=($dry_run)

		let sources = glob $source --exclude $in.exclude
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

		if not $is_target_dir and (($sources | length) > 1) {
			error make {
				msg: "Target path must be a directory when multiple sources are matched."
				code: "sys::config::link::target_not_directory"
				labels: {
					text: $"target: ($target)"
					span: (metadata $in.target).span
				}
				help: "Add a trailing '/' to the target to link many files while preserving their directory structure."
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

		let root = $in.root

		let ln_args = if $root {
			["doas"] ++ $ln_args
		} else {
			$ln_args
		}
	
		$sources | each { |src|
			try {
				if $dry_run {
					$ln_args ++ [ $src $target ]
				} else {
					run-external ...$ln_args $src $target
				}
			} catch { |err|
				error make {
					msg: $"Failed to create symbolic link for '($src)' to '($target)'."
				 	code: "sys::config::link::ln_failed"
				 	labels: {
						text: (if 'msg' in $err {
			   				$"Underlying error: ($err.msg)"
			   			} else {
			   			"Failed to execute 'ln' command."
			   			})
						span: (metadata $src).span
				 	}
					help: "Check that 'ln' is available, you have write permissions to the target directory, the source file exists and is readable, and no conflicting file exists at the target path."
				}
			}
		}
	}

	# Apply a specific configuration by label.
	export def apply [
		--label: string # The label of the configuration to apply.
		--dry-run # If specified, the command will only simulate the application without making any changes.
	]: record<configuration: table<label: string, file: table<source: string, target: string, root: bool, exclude: list<string>>>, devices: table<label: string, machine_id: string>> -> nothing {

		if ($label | is-empty) {
			error make {
				msg: "Configuration label must be specified."
				code: "sys::config::apply::label_missing"
				labels: {
					text: "The --label argument is required."
					span: (metadata $in).span
				}
				help: "Provide a valid configuration label to apply."
			}
		}

		let machine_id = host | get machine_id
		let device = $in.devices | where { $in.machine_id == $machine_id }
	
		if ($device | length) != 1 {
			error make {
				msg: "Could not find a unique device configuration for this machine_id"
				code: "sys::config::apply::device_not_found"
				labels: {
					text: $"machine_id: ($machine_id)"
					span: (metadata $device).span
				}
				help: "Ensure that the configuration file has a unique entry for this machine_id."
			}
		}
	
		let device_label = $device | first | get label

		let configuration = $in.configuration
			| where { $in.label == $label }

		if ($configuration | length) != 1 {
			error make {
				msg: "Could not find a unique configuration for the given label."
				code: "sys::config::apply::configuration_not_found"
				labels: {
					text: $"label: ($label)"
					span: (metadata $in).span
				}
				help: "Ensure that the configuration label exists and is unique."
			}
		}

		let configuration = $configuration | first
		let devices = $in.devices

		$configuration.file | each {
			{
				devices: $devices
				...$in
			} | link --dry-run=($dry_run) --device-label=($device_label)
		}
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