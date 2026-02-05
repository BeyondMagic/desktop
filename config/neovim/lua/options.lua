-------------------Less words-----------------------

local option                   = vim.api.nvim_set_option_value
local set                      = vim.api.nvim_set_var

--------------------Windows------------------------

vim.o.foldcolumn               = '0' -- '0' is not bad
vim.wo.foldlevel               = 99
vim.o.foldlevel                = 99  -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart           = 99
vim.o.foldenable               = false
-- vim.o.foldmethod               = 'marker' -- 'manual', 'indent', 'expr', 'syntax', 'diff', 'marker'

-- Fix moving through lines 'gk' and 'gj'
-- vim.wo.linebreak               = true

-- Use the new FileType system of Neovim.
-- let g:do_filetype_lua = 1

-- Show lines number (hybrid)
vim.wo.number                  = true
vim.wo.relativenumber          = true

-- To have a extra line :)
vim.o.cmdheight                = 0

-- Set wrap for words
vim.wo.wrap                    = true

-- Always show tabs
vim.o.showtabline              = 4

-- Show extra spaces.
vim.opt.list                   = true

-- Set wildmenu for later use
vim.o.wildmenu                 = true

-- Highlighting search
vim.o.hlsearch                 = true

-- Set ruler for better look
vim.o.ruler                    = true

-- No nice message
vim.o.hidden                   = true

-- Partial commands only in the screen
vim.o.showcmd                  = true

-- Match braces when inserting new ones :)
vim.o.showmatch                = true

-- Cursor line
---- Curosr column
vim.o.cursorline               = true
vim.wo.cursorline              = true
vim.o.cursorcolumn             = true
vim.wo.cursorcolumn            = true

-- Off scroll when moving through the buffer
vim.o.scrolloff                = 40

-- For terminal RGB colours
vim.go.termguicolors           = true

-- Colours, I believe
-- vim.go.t_Co = '256'
-- vim.go.t_ut = ''

-- Space for tabs
vim.o.laststatus               = 4

-- Space for tabs
vim.o.softtabstop              = 4

-- Expand tab to use spaces instead
vim.o.expandtab                = false

--  Space for tabs
vim.o.tabstop                  = 4

-- Space for tabs
vim.bo.shiftwidth              = 4

-- Space for tabs
vim.o.shiftwidth               = 4

-- Disable Python recommended style, which is terrible.
vim.g.python_recommended_style = 0

-- Format options to not create new lines with comments
vim.o.formatoptions            = 'tqj'

-- Mouse working with neovim
vim.o.mouse                    = 'a'

-- viminfo file
-- vim.o.viminfo = vim.o.viminfo .. '~/.config/nvim/viminfo'

-- Spell language to English (UK)
vim.o.spelllang                = 'en_gb'
vim.bo.spelllang               = 'en_gb'

-- Global statusline.
vim.opt.laststatus             = 3

-- Columns line "limit"
-- vim.o.cc = '85'

-- Set path for better searching across the system
-- vim.o.path = vim.o.path .. '**'

-- Complete options
vim.o.completeopt              = 'menuone,longest,noselect'
vim.o.shortmess                = vim.o.shortmess .. 'c'

-- Menu Transparency.
vim.go.pumblend                = 10

-- Disable Node.js provider
vim.g.loaded_node_provider     = 0

-- Disable Perl provider
vim.g.loaded_perl_provider     = 0

-- Disable Python provider
vim.g.loaded_python3_provider  = 0

-- Disable Ruby provider
vim.g.loaded_ruby_provider     = 0

-- Set fold method to expression
vim.opt.foldmethod = "expr"

-- Use treesitter for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Automatically open all folds
vim.opt.foldlevel = 99

--------------------Variables-----------------

set('one_allow_itali:set cursorlinec:set cursorlines', 1)
set('do_filetype_lua', 1)
set('MRU_File', '~/.cache/vim_mru_files')

--------------------API------------------------

-- Change title accordingly.
-- option('title', true)

-- Set ignorecase: search pattern ignores case
option('ignorecase', true, {})

-- Set smartcas: if search pattern has uppercase, search becomes case sensitive
option('smartcase', true, {})

-- Set clipboard to be global across the system
option('clipboard', 'unnamedplus', {})

-- Basic fold column
option('foldcolumn', '1', {})

-- Set dictionary to language spell
option('dictionary', '/usr/share/dict/words', {})

-- Wildignore for when opening files :0
option('wildignore', '*/tmp*/,*/node_modules/*,_site,*/__pycache__/,*/venv/*,*/target/*,*/.vim$,~$,*/.log', {})

-- File format for neovim reading
option('fileformat', 'unix', {})

-- Max column for syntax highlight
option('synmaxcol', 200, {})

-- lazyredraw
option('lazyredraw', true, {})
