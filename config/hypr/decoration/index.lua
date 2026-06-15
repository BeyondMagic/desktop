---@diagnostic disable: undefined-global

-- --------------------------------------------------------------------------
-- Decoration configuration
-- --------------------------------------------------------------------------
hl.config({
	decoration = {
		rounding = 8,
		dim_special = 0,
		shadow = {
			enabled = true,
			range = 36,
			render_power = 4,
			color = "rgba(00000044)",
		},
		blur = {
			enabled = true,
			xray = false,
			special = false,
			new_optimizations = true,
			size = 1,
			passes = 4,
			brightness = 1,
			noise = 0.01,
			contrast = 1,
			popups = true,
			popups_ignorealpha = 0.6,
		},
	},
})
