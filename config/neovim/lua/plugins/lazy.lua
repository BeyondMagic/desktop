return {


  -- Theme.
  --{
  --  dir      = '~/Programming/Projects/arcoiris-overhaul',
  --  priority = 1000,
  --  name     = 'arcoiris',
  --  init     = function()
  --    vim.api.nvim_create_autocmd('ColorScheme {
  --      callback = function() vim.api.nvim_set_hl(…) end,
  --      group = vim.api.nvim_create_augroup('config', {clear = false}),
  --      pattern = 'highlite',
  --    })
  --    vim.opt.termguicolors = true

  --    -- Setting our theem set.
  --    -- 1. 'light' for white theme.
  --    -- 2. 'dark' for dark theme.
  --    vim.api.nvim_set_option('background', 'dark')

  --    -- Set colorscheme theme.
  --    vim.cmd.colorscheme'arcoiris'

  --    -- Load main theme.
  --    require('utils')

  --  end,
  --  config = function()
  --    vim.opt.termguicolors = true

  --    -- Setting our theem set.
  --    -- 1. 'light' for white theme.
  --    -- 2. 'dark' for dark theme.
  --    vim.api.nvim_set_option('background', 'dark')

  --    -- Set colorscheme theme.
  --    vim.cmd.colorscheme'arcoiris'

  --    -- Load main theme.
  --    require('utils')
  --  end,
  --},

  -- CPP modern syntax.
  'bfrg/vim-cpp-modern',

  'hrsh7th/vim-vsnip',

  -- Indent align.
  'godlygeek/tabular',

  --
  -- Menu
  --
  -- Icons on menu
  'onsails/lspkind-nvim',

  -- NIM support (syntax, folding).
  --'baabelfish/nvim-nim',

  --
  -- Movement
  --

  -- List registers to open.
  'tversteeg/registers.nvim',

  -- Restore folds and cursor position
  'senderle/restoreview',

  -- Multi line like Sublime Text (My first Text Editor <3)
  --{, 'mg979/vim-visual-multi',
  --}

  -- Start a * or # search from a visual block.


  -- File manager (nnn)
  --'mcchrish/nnn.vim',

  -- Smooth scroll with neoscroll
  --{, 'karb94/neoscroll.nvim',
  --  config = require('neoscroll')
  --}

  -- File explorer
  -- {, 'kyazdani42/nvim-tree.lua',
  --   dependencies = 'kyazdani42/nvim-web-devicons',
  --   config = require('nvim-tree')
  -- }

  -- Lightspeed
  {
    'ggandor/lightspeed.nvim',
    dependencies = "tpope/vim-repeat"
  },

  -- Open the last used files.
  'yegappan/mru',

  -- Disables highlight after search.
  'romainl/vim-cool',

  --
  -- Appearance
  --

  'lervag/vimtex',

  -- Theme for sxhkdrc.
  'kovetskiy/sxhkd-vim',

  -- EWW parser for Vim
  'elkowar/yuck.vim',

  -- Close buffer without messing up with the window.
  'famiu/bufdelete.nvim',

  -- Show your functions/classes at the top of the screen.
  -- 'romgrk/nvim-treesitter-context',

  -- Tabs of buffers
  --{, 'akinsho/bufferline.nvim',
  --  --config = require('bufferline'),
  --  dependencies = 'kyazdani42/nvim-web-devicons'
  --}

  'nyoom-engineering/oxocarbon.nvim',

  -- JSONLS
  'b0o/schemastore.nvim',

  --
  --  LSP
  --
  -- 'MunifTanjim/eslint.nvim',
}
