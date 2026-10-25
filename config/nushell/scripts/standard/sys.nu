# João V. Farias © BeyondMagic 2025-2026 <beyondmagic@mail.ru>

# A helper function to simulate command execution in dry-run mode.
def dry-run []: list<string> -> nothing {
	print $in
}

# The path of this module file, used to derive the repository root.
const self_path = (path self)

# Resolve the path of the configuration file.
#
# Resolution order:
# 1. The path given by `--config`.
# 2. `./config.toml` in the current directory.
# 3. `config.toml` at the repository root, derived from this script's location.
def resolve-config [explicit: any]: nothing -> any {
	if not ($explicit | is-empty) {
		let path = $explicit | path expand
		if not ($path | path exists) {
			error make {
				msg: $"Configuration file '($path)' does not exist."
				code: "sys::config::not_found"
				help: "Provide the path to an existing 'config.toml'."
			}
		}
		return $path
	}

	let local = './config.toml' | path expand
	if ($local | path exists) {
		return $local
	}

	# <root>/config/nushell/scripts/standard/sys.nu -> <root>
	let root = (
		$self_path
		| path expand
		| path dirname
		| path dirname
		| path dirname
		| path dirname
		| path dirname
	)

	let candidate = $root | path join 'config.toml'
	if ($candidate | path exists) {
		return $candidate
	}

	error make {
		msg: "Could not find 'config.toml'."
		code: "sys::config::not_found"
		help: "Run from the repository root, pass --config, or check that the repository is linked into the nushell configuration directory."
	}
}

# Obtain the configuration record: piped from upstream or loaded from disk.
#
# The `path` field is the anchor for source patterns relative to the configuration file.
def obtain-config [explicit: any]: any -> record {
	let input = $in

	if ($input | is-empty) {
		let path = resolve-config $explicit
		{
			path: $path
			config: (open $path)
		}
	} else {
		{
			path: ($env.PWD | path join 'config.toml')
			config: $input
		}
	}
}

# Find the device label of this machine in the configured devices.
def device-label [devices: table<label: string, machine_id: string>]: nothing -> string {
	if ($devices | is-empty) {
		error make {
			msg: "No devices are configured."
			code: "sys::device::missing"
			help: "Add a [[devices]] entry for this machine in the configuration file."
		}
	}

	let machine_id = host | get machine_id

	let device = $devices | where { $in.machine_id == $machine_id }

	if ($device | length) != 1 {
		error make {
			msg: "Could not find a unique device configuration for this machine_id."
			code: "sys::device::not_found"
			labels: [
				{
					text: $"machine_id: ($machine_id)"
					span: (metadata $devices).span
				}
			]
			help: "Ensure that the configuration file has a unique [[devices]] entry for this machine_id."
		}
	}

	$device | first | get label
}

# Whether the service requires elevated privileges to manage.
def service-root [service: record]: nothing -> bool {
	$service | get -o root | default false
}

# The path where the service file of a managed service lives.
def service-file-path [service: record]: nothing -> path {
	let dir = if (service-root $service) {
		'/etc/dinit.d'
	} else {
		'~/.config/dinit.d' | path expand
	}

	$dir | path join $service.label
}

# Generate the content of the dinit service file of a managed service.
def service-file-content [service: record]: nothing -> string {
	let description = if ($service | get -o description | is-empty) {
		[]
	} else {
		[$"# ($service.description)"]
	}

	let dependencies = (
		$service
		| get -o depends_on
		| default []
		| each {|dependency| $"depends-on = ($dependency)" }
	)

	let lines = [
		...$description
		'type = process'
		$"command = ($service.command)"
		...$dependencies
	]

	($lines | str join "\n") + "\n"
}

# Write the dinit service file of a managed service.
def sync-service-file [
	service: record
	--dry-run
]: nothing -> nothing {

	# Skip when packages required by the service are not installed.
	let missing = (
		$service
		| get -o packages
		| default []
		| where {|package| (^pacman -Qq $package | complete).exit_code != 0 }
	)

	if ($missing | is-not-empty) {
		print $"Skipping service '($service.label)': missing packages: ($missing | str join ', ')"
		return
	}

	let path = service-file-path $service
	let content = service-file-content $service

	# Skip when the service file is already up to date.
	if ($path | path exists) {
		let current = try { open --raw $path } catch { '' }
		if $current == $content {
			print $"Service '($service.label)' is up to date."
			return
		}
	}

	if $dry_run {
		print $"[dry-run] write ($path)"
		return
	}

	let dir = $path | path dirname
	let root = (service-root $service)

	# Remove any existing file or symlink first, so writes never go through a symlink.
	if $root {
		if not ($dir | path exists) {
			run-external ...[ 'doas' 'mkdir' '--parents' $dir ]
		}
		run-external ...[ 'doas' 'rm' '--force' $path ]
		$content | run-external doas tee $path | ignore
	} else {
		if not ($dir | path exists) {
			mkdir $dir
		}
		run-external ...[ 'rm' '--force' $path ]
		$content | save --force --raw $path
	}

	print $"Installed service '($service.label)' at ($path)."
}

# Enable autostart of a managed service by linking it into the boot directory.
def sync-service-boot [
	service: record
	--dry-run
]: nothing -> nothing {

	let service_path = service-file-path $service
	let root = (service-root $service)

	if not ($service_path | path exists) {
		print $"Skipping autostart for '($service.label)': service file is not installed."
		return
	}

	let boot_dir = if $root {
		'/etc/dinit.d/boot.d'
	} else {
		'~/.config/dinit.d/boot.d' | path expand
	}

	let link_path = $boot_dir | path join $service.label

	if $dry_run {
		print $"[dry-run] link ($link_path) -> ($service_path)"
		return
	}

	if $root {
		if not ($boot_dir | path exists) {
			run-external ...[ 'doas' 'mkdir' '--parents' $boot_dir ]
		}
		run-external ...[ 'doas' 'ln' '--force' '--symbolic' '--relative' $service_path $link_path ]
	} else {
		if not ($boot_dir | path exists) {
			mkdir $boot_dir
		}
		run-external ...[ 'ln' '--force' '--symbolic' '--relative' $service_path $link_path ]
	}

	print $"Enabled autostart for '($service.label)'."
}

export module service {

	# Install managed services by label.
	#
	# Installs all services of this device when no label is given.
	export def install [
		label?: string # The label of the service to install.
		--config: path # Path to the configuration file (auto-discovered when omitted).
		--dry-run # If specified, the command will only simulate the installation.
	]: any -> nothing {
		let input = ($in | obtain-config $config)

		let configuration = $input.config
		let device_label = device-label ($configuration | get -o devices | default [])

		let services = (
			$configuration
			| get -o services
			| default []
			| where {|service| $device_label in ($service | get -o devices | default []) }
		)

		let selected = if ($label | is-empty) {
			$services
		} else {
			$services | where { $in.label == $label }
		}

		if ($selected | is-empty) {
			print "No services to install."
			return
		}

		$selected | each {|service|
			sync-service-file $service --dry-run=$dry_run
		}

		null
	}

	# Enable autostart of managed services by label.
	#
	# Enables all services of this device when no label is given.
	export def autostart [
		label?: string # The label of the service to enable autostarting for.
		--config: path # Path to the configuration file (auto-discovered when omitted).
		--dry-run # If specified, the command will only simulate the linking.
	]: any -> nothing {
		let input = ($in | obtain-config $config)

		let configuration = $input.config
		let device_label = device-label ($configuration | get -o devices | default [])

		let services = (
			$configuration
			| get -o services
			| default []
			| where {|service| $device_label in ($service | get -o autostart | default []) }
		)

		let selected = if ($label | is-empty) {
			$services
		} else {
			$services | where { $in.label == $label }
		}

		if ($selected | is-empty) {
			print "No services to autostart."
			return
		}

		$selected | each {|service|
			sync-service-boot $service --dry-run=$dry_run
		}

		null
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
	]: record<devices: list<record<label: string, machine_id: string>>, source: string, target: string, root: bool, exclude: list<string>> -> any {

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
				msg: $'No configuration files found to link from source "($source)"'
				code: "sys::config::link::sources_not_found"
				labels: {
					text: $"source pattern: ($source)"
					span: (metadata $source).span
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
	]: record<configuration: table<label: string, item: table<source: string, target: string, root: bool, exclude: list<string>>>, devices: table<label: string, username: string, machine_id: string>> -> nothing {

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

		$configuration.item | each {
			{
				devices: $devices
				...$in
			} | link --dry-run=($dry_run) --device-label=($device_label)
		}
	}
}

use config

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

# Link every configuration and install every service for this machine.
def build-system [
	loaded: record # The record returned by `obtain-config`.
	--only: list<string> = [] # Only apply these configuration labels; skips services.
	--dry-run
]: nothing -> nothing {

	let configuration = $loaded.config

	# Source patterns in the configuration are relative to the configuration file.
	cd ($loaded.path | path dirname)

	let devices = $configuration | get -o devices | default []
	let device_label = device-label $devices

	let configurations = $configuration | get -o configuration | default []

	if ($configurations | is-empty) {
		print "No configurations found."
	} else {
		if ($only | is-not-empty) {
			let unknown = $only | where { $in not-in $configurations.label }
			if ($unknown | is-not-empty) {
				error make {
					msg: $"Unknown configuration labels: ($unknown | str join ', ')"
					code: "sys::build::unknown_labels"
					help: $"Available labels: ($configurations.label | str join ', ')"
				}
			}
		}

		let selected = if ($only | is-empty) {
			$configurations
		} else {
			$configurations | where { $in.label in $only }
		}

		$selected | each {|rule|
			print $"Applying configuration '($rule.label)'..."

			$rule | get -o item | default [] | each {|item|
				let link_input = {
					devices: $devices
					...$item
				}

				let result = ($link_input | config link --device-label=($device_label) --dry-run=($dry_run))

				if $dry_run {
					$result | each {|command| $command | dry-run }
				}
			}
		}
	}

	# Install and enable services, unless only specific configurations were requested.
	if ($only | is-empty) {
		let services = (
			$configuration
			| get -o services
			| default []
			| where {|service| $device_label in ($service | get -o devices | default []) }
		)

		$services | each {|service|
			sync-service-file $service --dry-run=$dry_run
			sync-service-boot $service --dry-run=$dry_run
		}
	}

	null
}

# Build the system from the configuration file.
#
# Links every configuration and installs every service for this machine.
# The configuration file is auto-discovered: pass `--config`, run from a directory
# containing `config.toml`, or run from within the repository.
export def build [
	--config: path # Path to the configuration file (auto-discovered when omitted).
	--only: list<string> = [] # Only apply these configuration labels; skips services.
	--dry-run # If specified, only simulate what would be done.
]: any -> nothing {
	let loaded = ($in | obtain-config $config)

	build-system $loaded --only=$only --dry-run=$dry_run
}

# Validate the current machine against the configured devices and build the system.
export def setup [
	--config: path # Path to the configuration file (auto-discovered when omitted).
	--yes # Skip the confirmation prompt.
	--dry-run # If specified, only simulate what would be done.
]: any -> nothing {
	let loaded = ($in | obtain-config $config)

	let configuration = $loaded.config
	let device_label = device-label ($configuration | get -o devices | default [])

	let configurations = $configuration | get -o configuration | default []
	let services = (
		$configuration
		| get -o services
		| default []
		| where {|service| $device_label in ($service | get -o devices | default []) }
	)

	let machine = host

	print $"Machine '($machine.hostname)' matches device '($device_label)'."
	print $"- configurations: ($configurations | length)"
	print $"- services: ($services | length)"

	if not $yes {
		let answer = (['yes' 'no'] | input list 'Proceed with building the system?')
		if $answer != 'yes' {
			print "Cancelled."
			return
		}
	}

	build-system $loaded --dry-run=$dry_run
}

# View information about the system.
# 
# You must use one of the following subcommands. Using this command as-is will only produce this help message.
#
# This command has been extended from the built-in `sys` command, you can read more at: `https://github.com/BeyondMagic/desktop`
export def main []: nothing -> any {
	sys --help
}

export use config
export use service