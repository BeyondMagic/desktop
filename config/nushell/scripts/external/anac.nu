use ../fork.nu

# Run browser (firefox-nightly) that can be enabled with VPN.
export def main []: nothing -> any {
	$env.LANG = 'en_GB.UTF-8'
	$env.QT_QPA_PLATFORM = 'xcb'

	fork { exec firefox-nightly }
}
