return {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	depedencies = {
		-- Additional Nushell parser
		{ "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
	},
	opts = {
		ensure_installed = {
			"c",
			"lua",
			"markdown",
			"vim",
			"nu",
			"css",
			"html",
			"javascript",
			"latex",
			"scss",
			"tsx",
			"typst"
		},
		highlight = {
			enable = true
		},
		indent = {
			enable = true
		},
		auto_install = true
	}
}
