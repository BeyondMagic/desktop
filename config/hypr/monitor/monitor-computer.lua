---@diagnostic disable: undefined-global

-- --------------------------------------------------------------------------
-- Monitors
-- --------------------------------------------------------------------------

hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75.00Hz", position = "0x0", scale = 1, sdr_eotf = 1 })

-- hl.monitor({ output = "DVI-D-1", mode = "1920x1080R@75.00Hz", position = "1920x0", scale = 1, sdr_eotf = 1 })
hl.monitor({
	output = "DVI-D-1",
	-- mode = "modeline 154.00 1920 1968 2000 2080 1080 1083 1088 1111 +hsync -vsync",
	mode = "modeline 164.00 1920 1928 1960 2000 1080 1083 1088 1111 +hsync -vsync",
	-- mode = "modeline 166.50 1920 1968 2000 2080 1080 1083 1088 1111 +hsync -vsync",
	position = "1920x0",
	scale = 1,
	sdr_eotf = 1
})
