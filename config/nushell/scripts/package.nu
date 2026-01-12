# `paru` is a command for Arch-linux based distributions.
#export use ./external/paru.nu *
export use ./external/yay.nu *

# Upgrade all packages.
def update-system [
	--ignore: list<string> # Names of packages to ignore.
	--refresh = true # Refresh packages database.
	--force-refresh = false # Force-refrsh database.
]: nothing -> any {
	upgrade --ignore $ignore --refresh $refresh --force-refresh $force_refresh
}

export alias upgrade = update-system
