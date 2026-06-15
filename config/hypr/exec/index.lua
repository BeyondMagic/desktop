---@diagnostic disable: undefined-global

-- --------------------------------------------------------------------------
-- Environment and startup
-- --------------------------------------------------------------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("nu --login -c \"source ~/.config/nushell/login.nu\"")
	hl.exec_cmd("dbus-update-activation-environment --all")
	hl.exec_cmd("pkill --full --exact /usr/lib/xdg-desktop-portal")
	hl.exec_cmd("sleep 1.25s && hyprpm reload")
	hl.exec_cmd("sleep 2.00s && hyprctl reload")
	hl.exec_cmd("sleep 3s && dinitctl start fcitx5")
	hl.exec_cmd("sleep 5.25s && dinitctl start xdg-desktop-portal")
	hl.exec_cmd("sleep 2.00s && dinitctl start xdg-desktop-portal-hyprland")
	hl.exec_cmd("sleep 1.50s && dinitctl start awww-daemon")
	hl.exec_cmd("sleep 1.50s && dinitctl start nm-applet")
	hl.exec_cmd("sleep 2.50s && dinitctl start polkit-gnome-agent")
	hl.exec_cmd("sleep 1.50s && dinitctl start gammastep")
	hl.exec_cmd("sleep 1.50s && dinitctl start blueman-applet")
	hl.exec_cmd("sleep 1.50s && dinitctl start cliphist")
	hl.exec_cmd("sleep 1.50s && dinitctl start ags")
	hl.exec_cmd("sleep 1.50s && dinitctl start thunderbird")
	hl.exec_cmd("sleep 1.50s && dinitctl start flameshot")
	hl.exec_cmd("sleep 1.50s && dinitctl start wl-clip-persist")
	hl.exec_cmd("sleep 2.50s && dinitctl start beeper")
	hl.exec_cmd("sleep 2.25s && dinitctl start rclone-daemon")
	hl.exec_cmd("sleep 5s && dinitctl restart fcitx5")
end)
