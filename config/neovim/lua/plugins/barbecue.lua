-- Winbar with context.
return {
  'utilyre/barbecue.nvim',
  dependencies = {
    -- 'neovim/nvim-lspconfig',
    'SmiteshP/nvim-navic',
    'kyazdani42/nvim-web-devicons', -- Optional
  },
  -- If you set this to false, floating windows will look weird
  config = {
    exclude_float = true,

    -- Instead of excluding countless number of filetypes, barbecue tries to only show on some buftypes
    -- "": file buffer
    -- "nofile": e.g. nvim-tree and nvim-dap-ui
    -- "prompt": e.g. telescope.nvim and nvim-fzf
    -- "terminal": e.g. fterm.nvim and toggleterm.nvim
    -- ...
    include_buftypes = { "" },

    ---Filetypes not to enable winbar in.
    ---
    ---@type string[]
    exclude_filetypes = {
      '',
      'txt',
      'markdown',
    },

    -- :help events
    -- :help [event] (like :help BufWinEnter)
    update_events = {
      "BufWinEnter",
      "BufWritePost",
      "CursorMoved",
      "CursorMovedI",
      "TextChanged",
      "TextChangedI",
    },

    -- Show `~  ...` instead of `/  home  user  ...`
    tilde_home = true,

    -- Your winbar will have a little padding from the edge
    prefix = "  ",

    -- The sign between each entry
    separator = "  ",

    -- Show if lsp context is available but there is nothing to show
    no_info_indicator = "…",

    -- Symbol to show if file has been modified (not saved). It's usually `[+]` in vim
    -- `nil` to disable
    modified_indicator = nil,

    -- Icons passed to nvim-navic
    icons = {
      File          = " ",
      Module        = " ",
      Namespace     = " ",
      Package       = " ",
      Class         = " ",
      Method        = " ",
      Property      = " ",
      Field         = " ",
      Constructor   = " ",
      Enum          = "練",
      Interface     = "練",
      Function      = " ",
      Variable      = " ",
      Constant      = " ",
      String        = " ",
      Number        = " ",
      Boolean       = "◩ ",
      Array         = " ",
      Object        = " ",
      Key           = " ",
      Null          = "ﳠ ",
      EnumMember    = " ",
      Struct        = " ",
      Event         = " ",
      Operator      = " ",
      TypeParameter = " ",
      Define        = " ",
    },

    theme = {
      -- this highlight is used to override other highlights
      -- you can take advantage of its `bg` and set a background throughout your winbar
      -- (e.g. basename will look like this: { fg = "#c0caf5", bold = true })
      normal = { fg = COLOUR.fg_1 },

      -- these highlights correspond to symbols table from config
      --ellipsis = { fg = "#737aa2" },
      separator = { fg = COLOUR.fg_4 },
      --modified = { fg = "#737aa2" },

      -- these highlights represent the _text_ of three main parts of barbecue
      dirname = { fg = COLOUR.fg_5 },
      --basename = { bold = true },
      --context = {},

      -- these highlights are used for context/navic icons
      context_file           = { fg = COLOUR.red_0 },
      context_module         = { fg = COLOUR.yellow_0 },
      context_namespace      = { fg = COLOUR.blue_1 },
      context_package        = { fg = COLOUR.orange_0 },
      context_class          = { fg = COLOUR.green_0 },
      context_method         = { fg = COLOUR.violet_0 },
      context_property       = { fg = COLOUR.blue_3 },
      context_field          = { fg = COLOUR.violet_0 },
      context_constructor    = { fg = COLOUR.green_0 },
      context_enum           = { fg = COLOUR.orange_0 },
      context_interface      = { fg = COLOUR.blue_1 },
      context_function       = { fg = COLOUR.yellow_0 },
      context_variable       = { fg = COLOUR.red_0 },
      context_constant       = { fg = COLOUR.yellow_0 },
      context_string         = { fg = COLOUR.blue_1 },
      context_number         = { fg = COLOUR.orange_0 },
      context_boolean        = { fg = COLOUR.green_0 },
      context_array          = { fg = COLOUR.violet_0 },
      context_object         = { fg = COLOUR.blue_3 },
      context_key            = { fg = COLOUR.violet_0 },
      context_null           = { fg = COLOUR.green_0 },
      context_enum_member    = { fg = COLOUR.orange_0 },
      context_struct         = { fg = COLOUR.blue_1 },
      context_event          = { fg = COLOUR.yellow_0 },
      context_operator       = { fg = COLOUR.red_0 },
      context_type_parameter = { fg = COLOUR.yellow_0 },
    }
  }
}
