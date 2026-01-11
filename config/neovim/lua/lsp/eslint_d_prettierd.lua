local null_ls = require("null-ls")
local eslint = require("eslint")
-- local sources = { null_ls.builtins.formatting.prettierd }

null_ls.setup()

eslint.setup {
  bin = 'eslint_d',
  code_actions = {
    enable = true,
    apply_on_save = {
      enable = true,
      types = { "directive", "problem", "suggestion", "layout" },
    },
    disable_rule_comment = {
      enable = true,
      location = "separate_line", -- or `same_line`
    },
  },
  diagnostics = {
    enable = true,
    report_unused_disable_directives = false,
    run_on = "type", -- or `save`
  },
}
