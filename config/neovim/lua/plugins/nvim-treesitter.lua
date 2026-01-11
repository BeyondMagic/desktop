-- Treesitter (more highlight for syntax_on).

return {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	depedencies = {
		-- Additional Nushell parser
		{ "nushell/tree-sitter-nu", build = ":TSUpdate nu" },
	},
	config = function()
		local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

		parser_config.nu = {
			install_info = {
				url = "https://github.com/nushell/tree-sitter-nu",
				files = { "src/parser.c", "src/scanner.c" },
				branch = "main",
			},
			filetype = "nu",
		}

		require('nvim-treesitter.configs').setup {
			indent = {
				enable = true
			},

			highlight = {
				enable = true,
				disable = function(lang, bufnr) -- Disable in files with more than 5K
					return vim.api.nvim_buf_line_count(bufnr) > 5000
				end,
				--injections = {
				--  python = {
				--    docstrings: "markdown",
				--  },
				--}
			},
			--ensure_installed = { "nu" }, -- Ensure the "nu" parser is installed
			---- OPTIONAL!! These enable ts-specific textobjects.
			---- So you can hit `yaf` to copy the closest function,
			---- `dif` to clear the contet of the closest function,
			---- or whatever keys you map to what query.
			--textobjects = {
			--	select = {
			--		enable = true,
			--		keymaps = {
			--			-- You can use the capture groups defined in textobjects.scm
			--			-- For example:
			--			-- Nushell only
			--			["aP"] = "@pipeline.outer",
			--			["iP"] = "@pipeline.inner",

			--			-- supported in other languages as well
			--			["af"] = "@function.outer",
			--			["if"] = "@function.inner",
			--			["al"] = "@loop.outer",
			--			["il"] = "@loop.inner",
			--			["aC"] = "@conditional.outer",
			--			["iC"] = "@conditional.inner",
			--			["iS"] = "@statement.inner",
			--			["aS"] = "@statement.outer",
			--		}, -- keymaps
			--	}, -- select
			--}, -- textobjects
		}
	end
}
