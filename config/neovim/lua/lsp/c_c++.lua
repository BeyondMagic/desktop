-- local util = require "lspconfig.util"
---@diagnostic disable: undefined-global

vim.lsp.config("ccls", {
	init_options = {
		compilationDatabaseDirectory = "build",
		index = {
			threads = 0,
		},
		cache = {
			directory = vim.fs.normalize "~/.cache/ccls/",
		},
		-- on_attach = function(client, bufnr)
		-- 	if client.server_capabilities.documentSymbolProvider then
		-- 		require("nvim-navic").attach(client, bufnr)
		-- 	end
		-- end,
		-- clang = {
		-- 	includeArgs = { "-I/usr/include", "-I/usr/local/include" },
		-- 	excludeArgs = { "-frounding-math" },
		-- },
	}
})

vim.lsp.enable("ccls")
