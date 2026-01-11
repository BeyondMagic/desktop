-- Telescope, a see-all-through file manager.
return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim'
  },
  config = function()

    local actions    = require 'telescope.actions'
    local sorters    = require 'telescope.sorters'
    local previewers = require 'telescope.previewers'

    require 'telescope'.setup {
      defaults = {
        mappings = {
          i = {
            ['<ESC>'] = actions.close,
          },
        },
        vimgrep_arguments = {
          "rg",
          "-L",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },

        prompt_prefix      = "   ",
        selection_caret    = "  ",
        entry_prefix       = "  ",
        initial_mode       = "insert",
        selection_strategy = "reset",
        sorting_strategy   = "ascending",
        layout_strategy    = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width   = 0.55,
            results_width   = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width          = 0.87,
          height         = 0.80,
          preview_cutoff = 120,
        },
        file_sorter = sorters.get_fuzzy_file,
        file_ignore_patterns = { "node_modules" },
        generic_sorter = sorters.get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer   = previewers.vim_buffer_cat.new,
        grep_previewer   = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = previewers.buffer_previewer_maker,
      },

      extensions_list = { "themes", "terms" },
    }
  end
}
