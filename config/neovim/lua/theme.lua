local colorscheme_name = 'arcoiris'

-- Allow transparency.
vim.opt.termguicolors = true

-- Setting our theem set.
-- 1. 'light' for white theme.
-- 2. 'dark' for dark theme.
local option = vim.api.nvim_set_option_value
option('background', 'dark', {})

-- Set colorscheme theme.
vim.cmd.colorscheme(colorscheme_name)
local colours = require('colourschemes.' .. colorscheme_name .. '.colours.dark')

COLOUR = {}
for k, v in pairs(colours) do
  COLOUR[k] = v[1]
end
