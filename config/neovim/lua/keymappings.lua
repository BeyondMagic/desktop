---@diagnostic disable: undefined-global

local key = vim.api.nvim_set_keymap
local remap = { noremap = true, silent = true }

---------------------------Leader Keys---------------------------

-- Set with normal Vim opts, 'Space' as mapleader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set 'Space' as <NOP> key to leadermap key
key('n', '<Space>', '<NOP>', remap)

-- Find recursively TODOs, NOTEs, FIXITs, ... across the root folder subfiles.
key('n', '<Leader>l', ':TodoTelescope<CR>', remap)

-- Find recursively files across the root folder subfiles.
key('n', '<Leader>ff', ':lua require("telescope.builtin").find_files()<cr>', remap)

-- Find recursively a text across the root folder subfiles.
key('n', '<Leader>fg', ':lua require("telescope.builtin").live_grep()<cr>', remap)

-- Go to the next block.
--key('n', '<C-Down>', 'g%', remap )

-- Loop through brackets blocks.
--key('n', '<C-Up>', 'z%', remap )

-- Do just End on CTRL + End.
key('i', '<C-End>', '<End>', remap)
key('n', '<C-End>', '<End>', remap)

-- Do just Home on CTRL + Home.
key('i', '<C-Home>', '<End>', remap)

-- Highlight the word after pressing enter.
key('n', '<CR>',
  [[:let searchTerm = '\v<'.expand("<cword>").'>' <bar> let @/ = searchTerm <bar> echo '/'.@/ <bar> call histadd("search", searchTerm) <bar> set hls<cr>]],
  remap)

-- Highlight the visual selection after pressing enter.
key('v', '<CR>',
  [["*y:silent! let searchTerm = '\V'.substitute(escape(@*, '\/'), "\n", '\\n', "g") <bar> let @/ = searchTerm <bar> echo '/'.@/ <bar> call histadd("search", searchTerm) <bar> set hls<cr>]],
  remap)

-- Highlight the visual selection after pressing '.
-- key('v', "'",
-- [[y/\V<C-R>=escape(@",'\\')<CR><CR>]],
-- remap )

-- Go to the next tab.
key('i', '<A-TAB>', '<c-o>:tabNext<CR>', remap)
key('n', '<A-TAB>', ':tabNext<CR>', remap)

-- Go to next tab (buffer).
key('n', '<Tab>', '<Plug>(cokeline-focus-next)', remap)
key('n', '<S-Tab>', '<Plug>(cokeline-focus-prev)', remap)

--map('n', '<Tab>',     '',  { silent = true })
--map('n', '<S-Tab>',   '<Plug>(cokeline-focus-prev)',  { silent = true })
--y
key('n', '<Leader><', '<Plug>(cokeline-switch-prev)', remap)
key('n', '<Leader>>', '<Plug>(cokeline-switch-next)', remap)

-- To delete current buffer.
key('n', '<Leader>x', ':Bdelete<CR>', remap)

-- Just leave without saving.
key('n', '<Leader>qq', ':q<CR>', remap)

-- Toggle highlight of search
key('n', '<C-c>', ':set hlsearch!<CR>', remap)

-- Quick navigation between diagonostics.
key('n', '<Leader>D', ':TroubleToggle<CR>', remap)
key('n', '<Leader>d', ':lua vim.diagnostic.open_float()<CR>', remap)
key('n', '<Leader>N', ':lua vim.diagnostic.goto_next()<CR>', remap)
key('n', '<Leader>n', ':lua vim.diagnostic.goto_prev()<CR>', remap)

-- Toggle the sidebar tree of the root folder.
key('n', '<Leader>e', '', {
  noremap  = true,
  silent   = true,
  desc     = "Open the NeoTree without any warning messages...",
  callback = function()
    vim.cmd("Neotree toggle source=filesystem position=left")
  end
})

-- Writing mode with zen.
key('n', '<Leader>z', ':ZenMode<CR>', remap)

-- Close block-only highlighting mode.
--key('n', '<Leader>t', ':Twilight<CR>', remap )

-- Open n³ file explorer.
-- key('n', '<Leader>n', ':NnnPicker %:p:h<CR>', remap )

-- Try to correct the current word.
key('i', '<C-b>', 'ea<C-x><C-s>', remap)

-- Toggle built-in nvim spell checking.
key('n', '<F5>', ':setlocal spell!<CR>', remap)

-- Move lines normally like an IDE when line wraps
--key('i', '<Down>', [[v:count ? 'j' : '<c-o>gj']], { expr = true, noremap = true, silent = true  })
--key('i', '<Up>',   [[v:count ? 'k' : '<c-o>gk']], { expr = true, noremap = true, silent = true  })
--key('n', '<Down>', [[v:count ? 'j' : 'gj']],      { expr = true, noremap = true, silent = true  })
--key('n', '<Up>',   [[v:count ? 'k' : 'gk']],      { expr = true, noremap = true, silent = true  })

-- Set 'CTRL + v' as 'paster'
-- key('', '<C-v>', 'map"_d<Esc>i', remap )
key('v', '<C-v>', 'p', remap)

-- Set 'CTRL + x' as 'cut'
key('v', '<C-x>', 'mad`ai<Right>', { silent = true })

-- Set 'CTRL + c' as 'copier'
key('v', '<C-c>', 'may`ai', remap)
key('i', '<C-v>', '<Esc>:Registers<CR>', remap)


-- Create mark.
key('n', "'", '`', remap)

-- Move normaly bottom and up with C+Up and C+Down.
key('i', '<C-Up>', '<C-o>gk', remap)
key('i', '<C-Down>', '<C-o>gj', remap)
key('n', '<C-Up>', 'gk', remap)
key('n', '<C-Down>', 'gj', remap)


-- Set 'CTRL + z' as 'undo'
key('i', '<C-z>', '<Esc>ui', remap)

-- Set 'CTRL + y' as 'redo'
key('i', '<C-y>', '<Esc><C-r>', remap)

-- Set 'SHIFT + arrows' as 'select' like modern text-editor.
key('n', '<S-Up>', 'v<Up>', remap)
key('n', '<S-Down>', 'v<Down>', remap)
key('n', '<S-Left>', 'v<Left>', remap)
key('n', '<S-Right>', 'v<Right>', remap)

key('v', '<S-Up>', '<Up>', remap)
key('v', '<S-Down>', '<Down>', remap)
key('v', '<S-Left>', '<Left>', remap)
key('v', '<S-Right>', '<Right>', remap)

key('i', '<S-Up>', '<Esc>v<Up>', remap)
key('i', '<S-Down>', '<C-o>v<Down>', remap)
key('i', '<S-Left>', '<Esc>v<Left>', remap)
key('i', '<S-Right>', '<C-o>v<Right>', remap)

-- Set 'SHIFT + special-keys' as 'select' like a moden text editor.
key('i', '<S-Home>', '<Esc>v<Home>', remap)
key('i', '<S-End>', '<C-o>v<End><Left>', remap)

key('n', '<S-Home>', 'v<Home>', remap)
key('n', '<S-End>', 'v<End><Left>', remap)
key('n', '<S-PageUp>', '', remap)
key('n', '<S-PageDown>', '<Esc>:call Visual_Scroll_Down()<CR>i<Right><Left>', remap)

-- Paste registers.
-- These are to cancel the default behavior of d, D, c, C
-- to put the text they delete in the default register.
-- Note that this means e.g. "ad won't copy the text into
-- register a anymore.  You have to explicitly yank it.
-- key('n', 'd', "_d", remap )
-- key('v', 'd', "_d", remap )
-- key('n', 'D', "_D", remap )
-- key('v', 'D', "_D", remap )
-- key('n', 'c', "_c", remap )
-- key('v', 'c', "_c", remap )
-- key('n', 'C', "_C", remap )
-- key('v', 'C', "_C", remap )
-- key('n', 'p', "_p", remap )
-- key('v', 'p', "_p", remap )
-- key('n', 'P', "_P", remap )
-- key('v', 'P', "_P", remap )

-- Set a nice Page-Arrow transition.
-- key('i', '<PageUp>', '<Esc>:call Insert_Scroll_Up()<CR>i',                    remap )
-- key('i', '<PageDown>', '<Esc>:call Insert_Scroll_Down()<CR>i',                remap )
-- key('i', '<S-PageUp>', '<Esc>:call Visual_Scroll_Up()<CR>i<Right><Left>',     remap )
-- key('i', '<S-PageDown>', '<Esc>:call Visual_Scroll_Down()<CR>i<Right><Left>', remap )

-- Indent the current visual selection.
key('v', '<', '<gv', remap)
key('v', '>', '>gv', remap)

-- Set 'Backspace' as 'delete selection' for the visual selection.
key('v', '<BS>', '"_di', remap)

-- Paste and delete the first.
key('n', '<Leader>p', 'pggdd', remap)

-- Disable the button F1 that opens Neovim's help page.
key('n', '<F1>', '', remap)

-- Rename
key('n', '<Leader>rn', ':IncRename ', remap)

-- Go to the directory of current file.
key('n', '<Leader>cd', ':cd %:p:h<CR>', remap)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local ops = { buffer = ev.buf }

    vim.keymap.set('n', 'gD', function()
      vim.lsp.buf.declaration()
    end, ops)

    vim.keymap.set('n', 'gd', function()
      vim.lsp.buf.definition()
    end, ops)
  end
})

-- Copilot keybinds.
key("i", "<C-j>", 'copilot#Previous("<CR>")', remap)
key("i", "<C-k>", 'copilot#Next("<CR>")', remap)
key("i", "<C-l>", 'copilot#Accept("<CR>")', remap)

-- Open Neotree
key('n', '<C-k>', '', {
  noremap  = true,
  silent   = true,
  desc     = "Open the NeoTree without any warning messages...",
  callback = function()
    local result = vim.treesitter.get_captures_at_cursor(0)
    print(vim.inspect(result))
  end
})

key('n', '=F', '', {
  noremap  = true,
  silent   = true,
  desc     = "Format the current buffer asynchronously",
  callback = function()
    vim.lsp.buf.format { async = true }
  end
})
