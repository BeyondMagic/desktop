return {
	-- Basic styles
	Bold = { bold = true },
	Italic = { italic = true },
	Normal = { fg = COLOUR.fg_0, bg = COLOUR.bg_0 },
	Title = 'Bold',
	Underlined = { fg = COLOUR.green_4, underline = true },
	Whitespace = { fg = COLOUR.fg_6, bg = NONE },

	-- "Non"-text
	Conceal = 'NonText',
	EndOfBuffer = 'NonText',
	Ignore = { fg = COLOUR.fg_3 },
	NonText = { fg = COLOUR.bg_1, bg = COLOUR.bg_1 },
	ComplHint = { fg = COLOUR.fg_4 },

	-- Literals
	Constant = { fg = COLOUR.orange_2 },
	String = { fg = COLOUR.violet_0 },
	Character = { fg = COLOUR.red_1 },
	Number = { fg = COLOUR.red_2 },
	Boolean = { fg = COLOUR.yellow_0 },
	Float = 'Number',

	-- Syntax
	Comment = { fg = COLOUR.fg_5, italic = true },
	Conditional = { fg = COLOUR.blue_3, italic = true },
	Debug = 'WarningMsg',
	Delimiter = { fg = COLOUR.fg_1 },
	Exception = { fg = COLOUR.red_1, bold = true },
	Function = { fg = COLOUR.blue_0 },
	Identifier = function(self) return { fg = self.Normal.fg } end,
	Keyword = { fg = COLOUR.blue_4 },
	Label = { fg = COLOUR.violet_1, bold = true },
	Noise = 'Delimiter',
	Operator = { fg = COLOUR.green_0_0, bold = true },
	Repeat = { fg = COLOUR.green_4, italic = true },
	Statement = { fg = COLOUR.blue_3 },
	StorageClass = { fg = COLOUR.orange_2, bold = true },
	Structure = { fg = COLOUR.blue_1, bold = true },
	Tag = 'Underlined',
	Type = { fg = COLOUR.blue_3 },
	Typedef = { fg = COLOUR.blue_3, italic = true },

	-- Pre-processor
	Define = { fg = COLOUR.blue_1, nocombine = true },
	Include = { fg = COLOUR.fg_2, nocombine = true },
	Macro = { fg = COLOUR.blue_1, italic = true },
	PreCondit = { fg = COLOUR.yellow_1, italic = true },
	PreProc = { fg = COLOUR.yellow_1 },

	-- Special
	Special = { fg = COLOUR.violet_0, bold = true },
	SpecialChar = { fg = COLOUR.red_1, italic = true },
	SpecialComment = { fg = COLOUR.fg_3, bold = true, nocombine = true },
	SpecialKey = 'Character',

}
