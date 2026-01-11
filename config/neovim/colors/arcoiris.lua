-- This is the name of your colorscheme which will be used as per |g:colors_name|.
local colorscheme_name = 'arcoiris'

-- WARN: users shouldn't touch this.
vim.api.nvim_set_var('colors_name', colorscheme_name)

-- WARN: users shouldn't touch this.
COLOURSCHEME_ACCESS = 'colourschemes.' .. colorscheme_name

-- WARN: users shouldn't touch this.
local colorscheme = require(COLOURSCHEME_ACCESS)

COLOUR = nil

if vim.o.background == 'dark' then
  COLOUR = require(COLOURSCHEME_ACCESS .. '.colours.dark')
else
  COLOUR = require(COLOURSCHEME_ACCESS .. '.colours.light')
end

require(COLOURSCHEME_ACCESS .. '.highlights.groups')

colorscheme.highlight_terminal(
  require(COLOURSCHEME_ACCESS .. '.highlights.terminal')
)
