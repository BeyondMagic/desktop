return {
	TodoFgFIX = {fg = COLOUR.red_3},
	TodoFgHACK = {fg = COLOUR.yellow_0},
	TodoFgNOTE = {fg = COLOUR.violet_0, italic = true},
	TodoFgPERF = {fg = COLOUR.red_2, italic = true},
	TodoFgTODO = {fg = COLOUR.blue_1, italic = true},
	TodoFgWARN = {fg = COLOUR.orange_0},

	TodoBgFIX = function(self) return {fg = COLOUR.bg_0, bg = self.TodoFgFIX.fg, bold = true, italic = true, nocombine = true} end,
	TodoBgHACK = function(self) return {fg = COLOUR.bg_0, bg = self.TodoFgHACK.fg, bold = true, italic = true, nocombine = true} end,
	TodoBgNOTE = function(self) return {fg = COLOUR.bg_0, bg = self.TodoFgNOTE.fg, bold = true, italic = true, nocombine = true} end,
	TodoBgPERF = function(self) return {fg = COLOUR.bg_0, bg = self.TodoFgPERF.fg, bold = true, italic = true, nocombine = true} end,
	TodoBgTODO = function(self) return {fg = COLOUR.bg_0, bg = self.TodoFgTODO.fg, bold = true, italic = true, nocombine = true} end,
	TodoBgWARN = function(self) return {fg = COLOUR.bg_0, bg = self.TodoFgWARN.fg, bold = true, italic = true, nocombine = true} end,

	TodoSignFIX = 'TodoFgFIX',
	TodoSignHACK = 'TodoFgHACK',
	TodoSignNOTE = 'TodoFgNOTE',
	TodoSignPERF = 'TodoFgPERF',
	TodoSignTODO = 'TodoFgTODO',
	TodoSignWARN = 'TodoFgWARN',
}
