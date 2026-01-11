return {
	BufferAlternate = function(self) return {fg = self.BufferVisible.fg, bg = COLOUR.bg_2} end,
	BufferAlternateERROR = function(self) return {fg = COLOUR.red_3, bg = COLOUR.bg_4} end,
	BufferAlternateHINT = function(self) return {fg = COLOUR.violet_0, bg = COLOUR.bg_4} end,
	BufferAlternateIndex = function(self) return {fg = COLOUR.red_2, bg = COLOUR.bg_4} end,
	BufferAlternateINFO = function(self) return {fg = COLOUR.red_2, bg = COLOUR.bg_4} end,
	BufferAlternateMod = function(self) return {fg = self.BufferVisibleMod.fg, bg = COLOUR.bg_4, bold = true} end,
	BufferAlternateSign = function(self) return {fg = COLOUR.violet_0, bg = self.BufferAlternate.bg} end,
	BufferAlternateTarget = function(self) return {fg = self.BufferAlternateSign.fg, bg = COLOUR.bg_4, italic = true} end,
	BufferAlternateWARN = function(self) return {fg = COLOUR.orange_0, bg = COLOUR.bg_4} end,

	BufferCurrent = {fg = COLOUR.fg_0, bg = COLOUR.bg_4 },
	BufferCurrentERROR = function(self) return {fg = COLOUR.red_3, bg = self.BufferCurrent.bg} end,
	BufferCurrentHINT = function(self) return {fg = COLOUR.violet_0, bg = self.BufferCurrent.bg} end,
	BufferCurrentIndex = function(self) return {fg = COLOUR.red_2, bg = self.BufferCurrent.bg} end,
	BufferCurrentINFO = function(self) return {fg = COLOUR.red_2, bg = self.BufferCurrent.bg} end,
	BufferCurrentMod = {fg = COLOUR.yellow_1, bg = COLOUR.bg_0, bold = true},
	BufferCurrentSign = function(self) return {fg = COLOUR.blue_4, bg = self.BufferCurrent.bg} end,
	BufferCurrentTarget = 'BufferCurrentSign',
	BufferCurrentWARN = function(self) return {fg = COLOUR.orange_0, bg = self.BufferCurrent.bg} end,

	BufferInactive = 'BufferVisible',
	BufferInactiveERROR = function(self) return {fg = COLOUR.red_3, bg = self.BufferInactive.bg} end,
	BufferInactiveHINT = function(self) return {fg = COLOUR.violet_0, bg = self.BufferInactive.bg} end,
	BufferInactiveIndex = function(self) return {fg = COLOUR.red_2, bg = self.BufferInactive.bg} end,
	BufferInactiveINFO = function(self) return {fg = COLOUR.red_2, bg = self.BufferInactive.bg} end,
	BufferInactiveMod = 'BufferVisibleMod',
	BufferInactiveSign = 'BufferVisibleSign',
	BufferInactiveTarget = 'BufferVisibleTarget',
	BufferInactiveWARN = function(self) return {fg = COLOUR.orange_0, bg = self.BufferInactive.bg} end,

	BufferTabpages = {bold = true},
	BufferTabpageFill = 'TabLineFill',

	BufferVisible = {fg = COLOUR.fg_0, bg = COLOUR.bg_2},
	BufferVisibleERROR = function(self) return {fg = COLOUR.red_3, bg = self.BufferVisible.bg} end,
	BufferVisibleHINT = function(self) return {fg = COLOUR.violet_0, bg = self.BufferVisible.bg} end,
	BufferVisibleIndex = function(self) return {fg = COLOUR.red_2, bg = self.BufferVisible.bg} end,
	BufferVisibleINFO = function(self) return {fg = COLOUR.red_2, bg = self.BufferVisible.bg} end,
	BufferVisibleMod = function(self) return {fg = COLOUR.fg_1, bg = self.BufferVisible.bg, italic = true} end,
	BufferVisibleSign = function(self)
		local definition = self.BufferVisibleMod
		return {fg = definition.fg, bg = definition.bg, bold = true}
	end,
	BufferVisibleTarget = 'BufferVisibleSign',
	BufferVisibleWARN = function(self) return {fg = COLOUR.orange_0, bg = self.BufferVisible.bg} end,
}
