-- CSS + Less + SASS Language Server
---@diagnostic disable: undefined-global

vim.lsp.config("cssls", {
  cmd = { "vscode-css-languageserver", "--stdio" },
  filetypes = { "css", "scss", "less" },
  -- root_dir  = root_pattern("package.json", ".git") or bufdir,
  settings = {
    css = {
      validate = true,
    },
    less = {
      validate = true,
    },
    scss = {
      validate = true,
    },
  },
  single_file_support = true,
  capabilities = CAPABILITIES,
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, bufnr)
    end
  end,
})

vim.lsp.enable("cssls")
