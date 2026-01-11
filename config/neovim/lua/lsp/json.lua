---@diagnostic disable: undefined-global

vim.lsp.config("jsonls", {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
})

vim.lsp.enable("jsonls")
