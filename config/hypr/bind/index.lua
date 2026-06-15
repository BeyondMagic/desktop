---@diagnostic disable: undefined-global
local terminal = "foot"

-- --------------------------------------------------------------------------
-- Keybindings
-- --------------------------------------------------------------------------
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set '10+'"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set '10-'"), { locked = true, repeating = true })

hl.bind("SUPER + Delete", hl.dsp.window.close())
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + K", hl.dsp.layout("swapsplit"))

hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("ALT + Tab", hl.dsp.exec_cmd("hyprctl dispatch cyclenext && hyprctl dispatch bringactivetotop"))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + C",
	hl.dsp.exec_cmd("pkill fuzzel || cliphist list | fuzzel --match-mode=fzf --dmenu | cliphist decode | wl-copy"))

hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal .. " --window-size-pixels=100x100"))
hl.bind("SUPER + Backspace", hl.dsp.exec_cmd(terminal .. " --title=\"foot floating\""))
hl.bind("SUPER + SHIFT + Backspace", hl.dsp.exec_cmd(terminal .. " --title=\"foot floating\""))
hl.bind("ALT + Backspace", hl.dsp.exec_cmd(terminal .. " --title=\"foot floating\""))

hl.bind("SUPER + D", hl.dsp.exec_cmd("ags toggle launcher"))
hl.bind("Print", hl.dsp.exec_cmd("zoom.nu --type 'screenshot'"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("flameshot screen"))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("hyprpicker --autocopy"))

hl.bind("SUPER + F", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 0"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("hyprctl dispatch fullscreen 1"))

hl.bind("SUPER + Minus", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg splitratio -0.1"), { repeating = true })
hl.bind("SUPER + Equal", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg splitratio 0.1"), { repeating = true })
hl.bind("SUPER + Semicolon", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg splitratio -0.1"), { repeating = true })
hl.bind("SUPER + Apostrophe", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg splitratio 0.1"), { repeating = true })

hl.bind("CONTROL + SUPER + right", hl.dsp.focus({ workspace = "+1" }))
hl.bind("CONTROL + SUPER + left", hl.dsp.focus({ workspace = "-1" }))
hl.bind("CONTROL + SUPER + Equal", hl.dsp.exec_cmd("zoom.nu --type 'in'"), { repeating = true })
hl.bind("CONTROL + SUPER + Minus", hl.dsp.exec_cmd("zoom.nu --type 'out'"), { repeating = true })

hl.bind("SUPER + SHIFT + Right", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:+1"))
hl.bind("SUPER + SHIFT + Left", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:-1"))

-- for i = 1, 10 do
-- 	local key = i % 10
-- 	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
-- 	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
-- end
