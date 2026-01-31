return {
	-- Status Line
	StatusLine = {fg = COLOUR.fg_2, bg = COLOUR.bg_2},
	StatusLineNC = function(self) return {fg = COLOUR.fg_3, bg = self.StatusLine.bg} end,
	StatusLineTerm = 'StatusLine',
	StatusLineTermNC = 'StatusLineNC',

  -- Window
  VertSplit = 'Normal',

	-- Tabline
	TabLine = function(self) return {fg = COLOUR.fg_0, bg = self.StatusLine.bg} end,
	TabLineFill = {fg = COLOUR.bg_0, bg = COLOUR.bg_0},
	TabLineSel = function(self) return {fg = self.TabLine.fg, bg = COLOUR.bg_4} end,

	-- Line Highlighting
	CursorLine = {bg = COLOUR.bg_2},
	CursorLineNr = function(self) return {fg = COLOUR.violet_1, bg = self.LineNr.bg} end,
	LineNr = {fg = COLOUR.fg_3},
	QuickFixLine = function(self) return {bg = self.StatusLine.bg} end,
	Visual = {reverse = true},
	VisualNOS = {bg = COLOUR.bg_3},

	-- Popups
	FloatBorder = {fg = COLOUR.fg_3},
	Pmenu = {fg = COLOUR.fg_0, bg = COLOUR.bg_4},
	PmenuSbar = {bg = COLOUR.bg_3},
	PmenuSel = {fg = COLOUR.bg_0, bg = COLOUR.fg_0},
	PmenuThumb = {bg = COLOUR.fg_1},
	WildMenu = 'PmenuSel',

	-- Folds
	FoldColumn = { fg = COLOUR.blue_0, bold = true},
	Folded     = { fg = COLOUR.fg_5, bg = COLOUR.bg_2, italic = true},

	-- Diffs
	DiffAdd = { fg = COLOUR.green_3, bg = "none" },
	diffAdded = 'DiffAdd',
	DiffDelete = { fg = COLOUR.red_0, bg = "none" },
	DiffText = { fg = COLOUR.yellow_0, bg = "none" },
	DiffChange = { fg = COLOUR.blue_0, bg = "none" },
	-- DiffDelete = function(self) return {fg = self.DiffAdd.fg, bg = COLOUR.red_3} end,
	-- DiffText = function(self) return {fg = self.DiffAdd.fg, bg = COLOUR.yellow_0} end,
	diffRemoved = 'DiffDelete',

	-- Searching
	IncSearch = {reverse = true},
	MatchParen = {fg = COLOUR.green_0, bold = true, underline = true},
	Search = {sp = COLOUR.fg_1, underline = true},

	-- Spelling
	SpellBad = {sp = COLOUR.red_3, undercurl = true},
	SpellCap = {sp = COLOUR.yellow_0, undercurl = true},
	SpellLocal = {sp = COLOUR.green_0, undercurl = true},
	SpellRare = {sp = COLOUR.orange_0, undercurl = true},

	-- Conditional Column Highlighting
	ColorColumn = {reverse = false},
	SignColumn = {},

	-- Messages
	Error = {fg = COLOUR.red_3, bg = COLOUR.red_4, bold = true},
	ErrorMsg = {fg = COLOUR.red_3, bold = true},
	ModeMsg = {fg = COLOUR.yellow_0},
	Question = {fg = COLOUR.orange_2, underline = true},
	Todo = {fg = COLOUR.bg_0, bg = COLOUR.blue_3, bold = true},
	WarningMsg = {fg = COLOUR.orange_0, bold = true},

	-- Diagnostics
	debugBreakpoint = 'ErrorMsg',
	debugPC = 'ColorColumn',

	DiagnosticError = {fg = COLOUR.red_4, bg = COLOUR.red_5},
	DiagnosticFloatingError = 'ErrorMsg',
	DiagnosticSignError = 'DiagnosticFloatingError',

	DiagnosticWarn = {fg = COLOUR.yellow_2, bg = COLOUR.yellow_3},
	DiagnosticFloatingWarn = 'WarningMsg',
	DiagnosticSignWarn = 'DiagnosticFloatingWarn',

	DiagnosticHint = {fg = COLOUR.bg_0, bg = COLOUR.violet_0},
	DiagnosticFloatingHint = {fg = COLOUR.violet_0, italic = true},
	DiagnosticSignHint = 'DiagnosticFloatingHint',

	DiagnosticInfo = {fg = COLOUR.bg_0, bg = COLOUR.red_2},
	DiagnosticFloatingInfo = {fg = COLOUR.red_2, italic = true},
	DiagnosticSignInfo = 'DiagnosticFloatingInfo',

	DiagnosticUnderlineError = {sp = COLOUR.red_4, underline = true},
	DiagnosticUnderlineHint = {sp = COLOUR.violet_0, underline = true},
	DiagnosticUnderlineInfo = {sp = COLOUR.red_2, underline = true},
	DiagnosticUnderlineWarn = {sp = COLOUR.yellow_2, underline = true},

	-- Cursor
	Cursor = {reverse = true},
	CursorIM = 'Cursor',
	CursorColumn = {bg = COLOUR.bg_2},

	-- Misc
	Directory = {fg = COLOUR.red_2, bold = true},
	WinSeparator = {fg = COLOUR.bg_3, bg = COLOUR.bg_0},
}
