---@diagnostic disable: undefined-global

vim.lsp.config("elixirls", {
	-- Unix
	cmd = { "elixir-ls" },

	capabilities = CAPABILITIES,

	flags = {
		debounce_text_changes = 150,
	},
	elixirLS = {
		dialyzerEnabled = false,
		fetchDeps = false,
	},
})

vim.lsp.enable("elixirls")
