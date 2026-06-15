---@diagnostic disable: undefined-global

-- --------------------------------------------------------------------------
-- Cursor configuration
-- --------------------------------------------------------------------------
hl.config({
	cursor = {
		zoom_disable_aa = true,
		inactive_timeout = 4,
		hide_on_tablet = true,
		no_hardware_cursors = true,
	},
})

hl.env("XCURSOR_SIZE", "32")
hl.env("XCURSOR_THEME", "Bibata-Rainbow-Modern")

hl.exec_cmd("hyprctl setcursor Bibata-Rainbow-Modern 32")
hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme Bibata-Rainbow-Modern")
hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 32")
hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
