-- lua/git-hunks.lua

-- Create a table to hold the module's public functions.
local M = {}

-- The main setup function for the module.
function M.setup()
  -- Load the gitsigns plugin.
  local gitsigns = require('gitsigns')

  -- Configure gitsigns with our custom settings.
  gitsigns.setup({
    -- The on_attach function is a callback that runs for every buffer
    -- that gitsigns attaches to. This is the recommended place to set
    -- buffer-local keymaps for gitsigns functionality.
    on_attach = function(bufnr)
      -- A helper function to make setting keymaps more concise.
      local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr -- Make the keymap specific to the current buffer.
        opts.noremap = true  -- Recommended for all custom keymaps.
        opts.silent = true    -- Avoids command-line output.
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      -- Staging Keybinds
      map('n', ',', function() gitsigns.stage_hunk() end, { desc = 'Git: Stage Hunk' })
      map('v', ',', function() gitsigns.stage_hunk({vim.fn.line("."), vim.fn.line("v")}) end, { desc = 'Git: Stage Selection' })

      -- Unstaging Keybinds
      map('n', '.', function() gitsigns.stage_hunk() end, { desc = 'Git: Unstage Hunk' })
      map('v', '.', function() gitsigns.stage_hunk({vim.fn.line("."), vim.fn.line("v")}) end, { desc = 'Git: Unstage Selection' })

      -- Additional Recommended Workflow Keymaps
      -- Reset/revert changes in a hunk (destructive action).
      map('n', '<leader>gr', function() gitsigns.reset_hunk() end, { desc = 'Git: Reset Hunk' })
      map('v', '<leader>gr', function() gitsigns.reset_hunk({vim.fn.line("."), vim.fn.line("v")}) end, { desc = 'Git: Reset Selection' })

      -- Navigate between hunks.
      map('n', ']c', function() gitsigns.nav_hunk('next') end, { desc = 'Git: Next Hunk' })
      map('n', '[c', function() gitsigns.nav_hunk('prev') end, { desc = 'Git: Previous Hunk' })

      -- Preview the hunk diff in a floating window.
      map('n', '<leader>gp', function() gitsigns.preview_hunk() end, { desc = 'Git: Preview Hunk' })
    end,
  })
end

-- Return the module table so it can be required by other files.
return M
