-- Scrollbar with LSP

-- vim.cmd([[
--     augroup scrollbar_search_hide
--         autocmd!
--         autocmd CmdlineLeave : lua require('scrollbar').search_handler.hide()
--     augroup END
-- ]])

return {
  'petertriho/nvim-scrollbar',
  -- dependencies = 'kevinhwang91/nvim-hlslens',
  opts = {
    build_position_cb = function(plist)
      require("scrollbar").search_handler.show(plist.start_pos)
    end,
    show = true,
    handle = {
      text                = " ",
      color               = COLOUR.bar,
      hide_if_all_visible = true, -- Hides handle if all lines are visible
    },
    marks = {
      Search = { text = { "-", "=" }, priority = 0, color = "orange" },
      Error  = { text = { "-", "=" }, priority = 1, color = "red" },
      Warn   = { text = { "-", "=" }, priority = 2, color = "yellow" },
      Info   = { text = { "-", "=" }, priority = 3, color = "blue" },
      Hint   = { text = { "-", "=" }, priority = 4, color = "green" },
      Misc   = { text = { "-", "=" }, priority = 5, color = "purple" },
    },
    excluded_filetypes = {
      "neo-tree",
      "prompt",
      "TelescopePrompt",
    },
    autocmd = {
      render = {
        "BufWinEnter",
        "TabEnter",
        "TermEnter",
        "WinEnter",
        "CmdwinLeave",
        "TextChanged",
        "VimResized",
        "WinScrolled",
      },
    },
    handlers = {
      diagnostic = true,
      search     = false, -- Requires hlslens to be loaded
    },
  },
}
