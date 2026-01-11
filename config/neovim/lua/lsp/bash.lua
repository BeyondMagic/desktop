---@diagnostic disable: undefined-global

vim.lsp.config("bashls", {
  cmd = {
    "bash-language-server",
    "start",
  },
  filetypes = { "sh", "zsh" },
  capabilities = CAPABILITIES,
})

vim.lsp.enable("bashls")
