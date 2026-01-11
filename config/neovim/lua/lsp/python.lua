---@diagnostic disable: undefined-global

vim.lsp.config("pylsp", {
	on_attach = on_attach,
	settings = {
		pylsp = {
			plugins = {
				black = { enabled = true },
				isort = { enabled = true, profile = "black" },
				pycodestyle = {
					ignore = {
						'W191',
					},
				},
			},
		},
	},
})

vim.lsp.enable("pylsp")
