return {
	'nvimtools/none-ls.nvim',
	config = function()

		local null_ls = require 'null-ls'

		-- Register any number of sources simultaneously
		null_ls.setup {
			-- filetypes = { "markdown", "text" },
			sources = {

				-- null_ls.builtins.formatting.rome,
				-- null_ls.builtins.formatting.prettier,
				-- null_ls.builtins.diagnostics.write_good,
				-- null_ls.builtins.code_actions.gitsigns,

				-- Parse English
				-- null_ls.builtins.diagnostics.vale.with {
				--  filetypes = { "markdown", "tex", "txt" },
				--  -- command = "vale",
				--  -- args = { "--no-exit", "--output=JSON", "$FILENAME" },
				--}
			}
		}
	end
}
