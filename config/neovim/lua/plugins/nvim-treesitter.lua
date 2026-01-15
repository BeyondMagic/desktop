return {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	depedencies = {
		-- Additional Nushell parser
		{ "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
	},
	config = {
		ensure_installed = {
			"c", "lua", "markdown", "vim"
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
