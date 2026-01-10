#!/usr/bin/env nu
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2021-2025

# Kill all processes of the user launching the process.
export def clear []: nothing -> nothing {
	^pkill -U (whoami)
}

# Execute the compositor.
export def --env main []: nothing -> nothing {
	$env.XDG_SESSION_TYPE = 'wayland'
	$env.XDG_CURRENT_DESKTOP = 'Hyprland'

	exec dbus-run-session -- start-hyprland
}
