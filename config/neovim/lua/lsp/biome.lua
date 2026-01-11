-- local util = require 'lspconfig.util'
---@diagnostic disable: undefined-global

vim.lsp.config("biome", {
	-- cmd = {
	-- 	"biome",
	-- 	"lsp-proxy",
	-- },
	-- filetypes = {
	-- 	'javascript',
	-- 	'javascriptreact',
	-- 	'typescript',
	-- 	'typescriptreact',
	-- 	'json'
	-- },
	-- single_file_support = true,
	on_attach = function(client, bufnr)
		if client.server_capabilities.documentSymbolProvider then
			require('nvim-navic').attach(client, bufnr)
		end
	end,
})

vim.lsp.enable("biome")
