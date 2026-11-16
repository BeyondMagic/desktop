-- João Farias © BeyondMagic <beyondmagic@mail.ru> 2023-2026

---@diagnostic disable: undefined-global
hl.window_rule({
	name = "tensaku-editor",
	match = { title = "^(Tensaku)" },
	center = true,
	float = true,
	-- move = "(-1*monitor_w) 0",
	-- size = "(monitor_w*2) monitor_h",
	-- monitor = "HDMI-A-1",
	pin = true,
})


-- For mpv, always float
hl.window_rule({
	name = "mpv",
	match = { class = "mpv" },
	float = true,
	-- move = "(-1*monitor_w) 0",
	-- size = "(monitor_w*2) monitor_h",
	-- monitor = "DP-1", -- DP-1
	-- pin = true,
})
