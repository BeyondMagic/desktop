---@diagnostic disable: undefined-global

vim.lsp.config("typst_lsp", {

	-- Default.
	capabilities = CAPABILITIES,
	on_attach = function(client, bufnr)
		if client.server_capabilities.documentSymbolProvider then
			require("nvim-navic").attach(client, bufnr)
		end
	end,
})

vim.lsp.enable("typst_lsp")
