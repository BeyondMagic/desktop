---@diagnostic disable: undefined-global

vim.lsp.config("nushell", {
	cmd = {
		"nu",
		"--no-config-file",
		"--include-path",
		"/home/dream/.config/nushell/scripts",
		"--lsp",
	},

	on_attach = function(client, bufnr)
		if client.server_capabilities.documentSymbolProvider then
			require("nvim-navic").attach(client, bufnr)
		end
	end,
})

vim.lsp.enable("nushell")
