---@diagnostic disable: undefined-global

vim.lsp.config("ts_ls", {

	settings = {
		implicitProjectConfiguration = {
			checkJs = true,
		},
	},

	on_attach = function(client, bufnr)
		if client.server_capabilities.documentSymbolProvider then
			require("nvim-navic").attach(client, bufnr)
		end
	end,
})

vim.lsp.enable("ts_ls")
