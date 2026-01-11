vim.filetype.add({
  extension = {
    dbml = 'dbml',
  },
})

-- 1. Define the DBML configuration
vim.lsp.config('dbml', {
  cmd = { 'dbml-lsp' },
  filetypes = { 'dbml' },
  root_markers = { '.git' },
})

-- 2. Enable the server
vim.lsp.enable('dbml')
