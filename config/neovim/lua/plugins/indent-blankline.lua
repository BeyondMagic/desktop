vim.opt.listchars:append("space:⋅")

local highlight = {
	"IndentBlankLine",
	"Whitespace",
}

-- Indent lines without conceal!!!
return {
	'lukas-reineke/indent-blankline.nvim',
	main = 'ibl',
	event = "VeryLazy",
	opts = {},
	config = function ()
		require 'ibl'.setup {
			exclude = {
				filetypes = { "alpha", },
				buftypes = { "terminal" },
			},
			indent = {
				highlight = highlight,
				char = "",
				tab_char = "╎",
			},
			whitespace = {
				highlight = highlight,
				remove_blankline_trail = true,
			},
			-- scope = { enabled = false },
		}
	end
}
