---@diagnostic disable: undefined-global
hl.window_rule({
	name = "flameshot-overlay",
	match = { title = "^(flameshot)" },
	float = true,
	move = "(-1*monitor_w) 0",
	size = "(monitor_w*2) monitor_h",
	monitor = "HDMI-A-1",
	pin = true,
})
