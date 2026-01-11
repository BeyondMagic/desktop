-- The bottom line (the main bar).

return {
  'nvim-lualine/lualine.nvim',
  branch = 'master',
  -- Some optional icons
  dependencies = 'kyazdani42/nvim-web-devicons',
  config = function()
    -- Eviline config for lualine
    -- Author: shadmansaleh
    -- Credit: glepnir
    local lualine = require('lualine')

    -- auto change color according to neovims mode
    local mode_color = {
      n      = { 'Normal'           ,COLOUR.fg_1 },
      i      = { 'Insert'           ,COLOUR.green_3 },
      v      = { 'Visual'           ,COLOUR.green_1 },
      [''] = { 'Visual Block'     ,COLOUR.green_0 },
      V      = { 'Visual Line'      ,COLOUR.violet_2 },
      c      = { 'Command-Line'     ,COLOUR.violet_0 },
      no     = { 'Operator-Pending' ,COLOUR.blue_1 },
      s      = { 'Select'           ,COLOUR.orange_1 },
      S      = { 'Select'           ,COLOUR.yellow_0 },
      [''] = { 'Select'           ,COLOUR.orange_0 },
      ic     = { 'Ins-Complete'     ,COLOUR.yellow_1 },
      R      = { 'Replace'          ,COLOUR.red_1 },
      Rv     = { 'Virtual'          ,COLOUR.red_2 },
      cv     = { 'Ex'               ,COLOUR.green_5 },
      ce     = { 'Normal Ex'        ,COLOUR.blue_2 },
      r      = { 'Hit-Enter'        ,COLOUR.violet_1 },
      rm     = { '--More'           ,COLOUR.blue_0 },
      ['r?'] = { ':Confirm'         ,COLOUR.green_4 },
      ['!']  = { 'Shell'            ,COLOUR.blue_3 },
      t      = { 'Terminal'         ,COLOUR.blue_4 }
    }

    -- Conditional for a certain part of the bar to be rendered.
    local conditions = {

      -- To see if the buffer is not empty.
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
      end,

      -- If buffer is not X name.
      is_not_buffer = function(name)
        return vim.api.nvim_buf_get_name(0) == name
      end,

      -- To hide if is biggerr than certain width.
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,

      -- To check if is in git environment.
      check_git_workspace = function()
        local filepath = vim.fn.expand('%:p:h')
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end,

      -- If it's a type of writing file.
      writing_file = function()
        if vim.bo.filetype == "md" or vim.bo.filetype == "text" or vim.bo.filetype == "markdown" then return true end
      end,

      -- To check if spell is activated.
      spell_activated = function ()
        if (vim.api.nvim_win_get_option(0, 'spell')) then return true end
      end

    }

    -- Lualine main configuration, very important to define.
    local config = {

      -- Options main.
      options = {
        -- Disable sections and component separators
        component_separators = '',
        section_separators = '',

        -- Filetypes to disable lualine for.
        disabled_filetypes = {
          statusline = { 'neo-tree' }, -- only ignores the ft for statusline.
          winbar     = { 'neo-tree' }, -- only ignores the ft for winbar.
        },


        -- enable global statusline (have a single statusline
        -- at bottom of neovim instead of one for  every window).
        -- This feature is only available in neovim 0.7 and higher.
        globalstatus = true,

        theme = {
          -- We are going to use lualine_c an lualine_x as left and
          -- right section. Both are highlighted by c theme .  So we
          -- are just setting default looks o statuslinbar_e
          normal = { c = { fg = COLOUR.fg_4, bg = COLOUR.bg_2 } },
          inactive = { c = { fg = COLOUR.fg_3, bg = COLOUR.bg_3 } },
        },

        -- #. Sets how often lualine should refreash it's contents (in ms)
        refresh = {

          -- 1. The refresh option sets minimum time that lualine tries
          statusline = 50,

          -- 2. To maintain between refresh. It's not guarantied if situation
          tabline = 1000,

          -- 3. rises that lualine needs to refresh itself before this time
          winbar = 1000

          -- Also you can force lualine's refresh by calling refresh function
          --   like require('lualine').refresh()
        }

      },

      -- All sections of the bar.
      sections = {
        -- These are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_d = {},
        lualine_x = {
          {
              'copilot',
              -- Default values
              symbols = {
                  status = {
                      icons = {
                          enabled = " ",
                          sleep = " ",   -- auto-trigger disabled
                          disabled = " ",
                          warning = " ",
                          unknown = " "
                      },
                      hl = {
                          enabled = "#50FA7B",
                          sleep = "#AEB7D0",
                          disabled = "#6272A4",
                          warning = "#FFB86C",
                          unknown = "#FF5555"
                      }
                  },
                  spinners = "dots", -- has some premade spinners
                  spinner_color = "#6272A4"
              },
              show_colors = false,
              show_loading = true
          },
          'encoding',
          'fileformat',
          'filetype'
        },
      },

      -- Just remove the defaults.
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_d = {},
        lualine_x = {}
      },

      --tabline = {},
      --winbar = {
      --  -- These are to remove the defaults
      --  lualine_a = {},
      --  lualine_b = {},
      --  lualine_y = {},
      --  lualine_z = {},
      --  -- These will be filled later
      --  lualine_c = {},
      --  lualine_x = {},
      --},

      --inactive_winbar = {
      --  lualine_a = {},
      --  lualine_b = {},
      --  lualine_y = {},
      --  lualine_z = {},
      --  lualine_c = {},
      --  lualine_x = {},
      --},
      --extensions = {}

    }

    ------------------------------------------------------
    -- 1. Inserts a component in lualine_c at left section

    local insert = {

      status = {

        left = function (component)
          table.insert(config.sections.lualine_c, component)
        end,

        -- Inserts a component in lualine_x ot right section
        right = function (component)
          table.insert(config.sections.lualine_x, component)
        end,

      },

      --window = {

      --  left = function (component)
      --    table.insert(config.winbar.lualine_c, component)
      --  end,

      --  -- Inserts a component in lualine_x ot right section
      --  right = function (component)
      --    table.insert(config.winbar.lualine_x, component)
      --  end,

      --}

    }

    -- 1. Statusline.
    -----------------------------------------------------

    -- #. To get back the name of the mode.
    insert.status.left({
      function()
        return '▊ ' .. mode_color[vim.fn.mode()][1]
      end,
      color = function()
        return { fg = mode_color[vim.fn.mode()][2] }
      end,
      padding = { right = 1 },
    })

    -- #. Filesize component.
    insert.status.left({
      'filesize',
    })

    --insert.status.left({
    --  'filename',
    --  cond = conditions.buffer_not_empty,
    --  color = { fg = COLOUR.gray, gui = 'bold' },
    --})

    insert.status.left({
      'location',
    })

    insert.status.left({ 'progress', color = { fg = COLOUR.fg_0, gui = 'bold' } })


    insert.status.left({
      'diff',
      colored = true, -- Displays a colored diff status if set to true
      diff_color = {
        -- Same color values as the general color option can be used here.
        added    = { fg = COLOUR.green_0 },  -- Changes the diff's added color
        modified = { fg = COLOUR.blue_1 },  -- Changes the diff's modified color
        removed  = { fg = COLOUR.red_1 }  -- Changes the diff's removed color you
      },
      symbols = { added = ' ', modified = ' ', removed = ' ' }, -- Changes the symbols used by the diff.
      cond = conditions.hide_in_width,
      source   = nil, -- A function that works as a data source for diff.
      -- It must return a table as such:
      --   { added = add_count, modified = modified_count, removed = removed_count }
      -- or nil on failure. count <= 0 won't be displayed.
    })

    -- Function to show the spell_language if spell si activated.
    insert.status.left({
      function()
        return '  ' .. vim.api.nvim_get_option('spelllang')
      end,
      cond = conditions.spell_activated,
      color = { fg = COLOUR.green_3, gui = 'bold' },
    })

    -- Insert mid section. You can make any number of sections in neovim :)
    -- for lualine it's any number greater then 2
    insert.status.left({
      function()
        return '%='
      end,
    })

    insert.status.left({
      -- Lsp server name .
      function()
        --local msg = 'No Active Lsp'
        local buf_ft = vim.api.nvim_get_option_value('filetype', {buf = 0})
        local clients = vim.lsp.get_clients()
        if next(clients) == nil then
          return ''
        end
        for _, client in ipairs(clients) do
          local filetypes = client.config.filetypes
          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            return client.name
          end
        end
        return ''
      end,
      icon = ' ',
      color = { fg = COLOUR.fg_0, gui = 'bold' },
    })


    insert.status.right({
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      diagnostics_color = {
        -- Same values as the general color option can be used here.
        error = { fg = COLOUR.red_1 }, -- Changes diagnostics' error color.
        warn  = { fg = COLOUR.yellow_0 }, -- Changes diagnostics' warn color.
        info  = { fg = COLOUR.blue_3 }, -- Changes diagnostics' info color.
        hint  = { fg = COLOUR.violet_1 }  -- Changes diagnostics' hint color.,
      },
      colored = true,           -- Displays diagnostics status in color if set to true.
      update_in_insert = false, -- Update diagnostics in insert mode.
      always_visible = false,   -- Show diagnostics even if there are none.
    })

    insert.status.right({
      -- This function serve to count all the words in the buffer and return a number.
      -- @return number The amount of words.
      function()
        if vim.fn.wordcount().visual_words == 1 then
          return tostring(vim.fn.wordcount().visual_words) .. " word"
        elseif not (vim.fn.wordcount().visual_words == nil) then
          return tostring(vim.fn.wordcount().visual_words) .. " words"
        else
          return tostring(vim.fn.wordcount().words) .. " words"
        end
      end,
      cond = conditions.writing_file,
      color = { fg = COLOUR.fg_0, gui = 'bold' },
    })

    -- Add components to right sections
    insert.status.right({
      'o:encoding', -- option component same as &encoding in viml
      fmt = string.upper, -- I'm not sure why it's upper case either ;)
      cond = conditions.hide_in_width,
      color = { fg = COLOUR.fg_0, gui = 'bold' },
    })

    insert.status.right({
      'fileformat',
      fmt = string.upper,
      icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
      color = { fg = COLOUR.fg_0, gui = 'bold' },
    })

    insert.status.right({
      'branch',
      icon = '',
      color = { fg = COLOUR.fg_0, gui = 'bold' },
    })

    --insert.status.right({
    --  'diff',
    --  -- Is it me or the symbol for modified us really weird
    --  symbols = { added = ' ', modified = '柳 ', removed = ' ' },
    --  diff_color = {
    --    added = { fg = COLOUR.green },
    --    modified = { fg = COLOUR.orange },
    --    removed = { fg = COLOUR.red },
    --  },
    --  cond = conditions.hide_in_width,
    --})

    insert.status.right({
      function()
        return '▊'
      end,
      color = { fg = COLOUR.bar },
      padding = { left = 1 },
    })

    -- Copilot Status:

    ----------------------------------------------------

    -- 2. Winbar.
    ----------------------------------------------------

    -- insert.window.left({
    --   function ()
    --     return " I feel like dreaming!"
    --   end,
    --   color = { fg = COLOUR.fg, bg = COLOUR.bg_light, gui = 'bold' },
    -- })

    ----------------------------------------------------

    -- Now don't forget to initialize lualine
    lualine.setup(config)
  end
}
