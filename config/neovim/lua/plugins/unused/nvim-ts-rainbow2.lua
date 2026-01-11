return {
  'HiPhish/nvim-ts-rainbow2',
  dependencies = 'nvim-treesitter',
  config = function()
    require'nvim-treesitter.configs'.setup {
      rainbow = {
        enable = true,
        -- list of languages you want to disable the plugin for
        --disable = { 'jsx', 'cpp' },
        -- Which query to use for finding delimiters
        query = 'rainbow-parens',
        -- Highlight the entire buffer all at once
        strategy = require('ts-rainbow').strategy.global,
      },
      hlgroups = {
       'TSRainbowRed',
       'TSRainbowYellow',
       'TSRainbowBlue',
       'TSRainbowOrange',
       'TSRainbowGreen',
       'TSRainbowViolet',
       'TSRainbowCyan'
      },
    }
  end
}
