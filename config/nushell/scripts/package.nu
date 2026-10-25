# `paru` is a command for Arch-linux based distributions.
#export use ./external/paru.nu *
export use ./external/yay.nu *
use ./standard/sys.nu

# Upgrade all packages.
def update-system [
	--ignore: list<string> # Names of packages to ignore.
	--refresh = true # Refresh packages database.
	--force-refresh = false # Force-refrsh database.
	--build # Build the system configuration after upgrading.
]: nothing -> any {
	upgrade --ignore $ignore --refresh $refresh --force-refresh $force_refresh

	if $build {
		print 'Building the system...'

		sys build
	}
}

export alias upgrade = update-system
