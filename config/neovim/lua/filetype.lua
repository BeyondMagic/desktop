
-- To be used anywhere.
local function job (command)

  vim.api.nvim_command( "call jobstart('" .. command .."')" )

end

-- https://github.com/BeyondMagic/whitedove
-- Personal website.
local function build (type)

  vim.api.nvim_create_autocmd( 'BufWritePost', {
    pattern = '<buffer>',
    callback = function ()
      job( './build.sh ' .. type )
    end,
  })

end

local function format ()
  vim.api.nvim_create_autocmd( 'BufWritePost', {
    pattern = '<buffer>',
    callback = function ()
      vim.lsp.buf.format()
    end
  })
end

local function gtk_build ()
  vim.api.nvim_create_autocmd( 'BufWritePost', {
    pattern = '<buffer>',
    callback = function ()
      job('killall -HUP xsettingsd')
    end
  })

  return 'conf'
end

-- In init.lua or filetype.nvim's config file
vim.filetype.add({

    extension = {

        h = function()
            -- Use a lazy heuristic that #including a C++ header means it's a
            -- C++ header
            if vim.fn.search("\\C^#include <[^>.]\\+>$", "nw") == 1 then
                return "cpp"
            end
            return "c"
        end,

        -- Spelling fix.
        -- md = function()
        --   vim.api.nvim_command('setlocal spell!')

        --   vim.api.nvim_create_autocmd( 'BufWritePost', {
        --     callback = function ()
        --       -- The path of the file.
        --       local buffer_name  = vim.api.nvim_buf_get_name(0)

        --       -- To transfrom the path "../../a.pdf" to "a".
        --       local name_file    = buffer_name:match("[^/]*.md$")
        --             name_file    = name_file:sub(0, #name_file - 3)

        --       local directory    = string.match(buffer_name, ".+/")
        --       
        --       job("pandoc " .. buffer_name .. " -s -o " .. directory .. name_file .. ".pdf")
        --     end,
        --   })
        --   return "markdown"
        -- end,

        --
        csv = "csv",
        cl  = "opencl",
        env = "env",
        rasi = "rasi",
        sh = 'zsh',
		spim = 'asm',
		typst = 'typst',

        -- Latex
--         tex = function()
--           vim.api.nvim_create_autocmd( 'BufWritePost', {
--             callback = function ()
--               local cache_folder = '/home/dream/.cache/latex'
--               -- The path of the file.
--               local buffer_name  = vim.api.nvim_buf_get_name(0)
-- 
--               -- To transfrom the path "../../a.pdf" to "a".
--               local name_file    = buffer_name:match("[^/]*.tex$")
--                     name_file    = name_file:sub(0, #name_file - 4)
-- 
--               local directory    = string.match(buffer_name, ".+/")
--               
--               job("xelatex -output-directory \"" .. cache_folder .. "\" \"" .. buffer_name .. "\" && /usr/bin/cp -f \"" .. cache_folder .. "/" .. name_file .. ".pdf\" \"" .. directory .. "\"")
--               --job("pdflatex -output-directory " .. cache_folder .. " " .. buffer_name .. " && /usr/bin/cp -f " .. cache_folder .. "/" .. name_file .. ".pdf " .. directory)
--             end,
--           })
--           return 'tex'
--         end,
-- 
    },
    pattern = {

      -- Go to root configuration of some projects.
      --[".*config/nvim/.*"] = function()
      --  vim.api.nvim_command('cd ~/.config/nvim/')
      --end,
      --[".*config/wired/.*"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Personal/magic/.config/wired/')
      --  return 'rust'
      --end,
      --[".*Projects/flarity/.*"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Projects/flarity/')
      --end,
      --[".*config/eww/.*"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Personal/magic/.config/eww/')
      --end,
      --[".*config/picom/.*"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Personal/magic/.config/picom/')
      --end,
      [".*config/xorg/.*"] = function()
        vim.api.nvim_command('cd ~/.config/xorg/')

        -- Make up the XORG.
        vim.api.nvim_create_autocmd( 'BufWritePost', {
          pattern = '<buffer>',
          callback = function ()
            os.execute( "xrdb ~/.config/xorg/XResources" )
          end,
        })

        vim.api.nvim_command('HexokinaseTurnOn')

        return 'xdefaults'
      end,

      ---- Typescript Projects
      [".*/source/ts/.*ts"] = function()
        format()
		build("ts")
      end,
      [".*/source/.*json"] = function()
        format()
		build("ts")
      end,
      [".*/source/scss/.*scss"] = function()
        -- format()
		build("scss")
      end,
      [".*/source/html/.*html"] = function()
        format()
		build("html")
      end,

      [".*/share/themes/.*/.*scss"] = function()
        vim.api.nvim_command('HexokinaseTurnOn')
        return gtk_build()
      end

      ---- Personal website.
      ---- [".*Personal/beyondmagic.space/source/typescript/global.ts"] = function()
      ----   vim.api.nvim_command('cd ~/Programming/Personal/beyondmagic.space/')
      ----   build('ts global')
      ---- end,
      --[".*Personal/beyondmagic.space/source/typescript/.*ts"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Personal/beyondmagic.space/')
      --  build('ts index')
      --end,
      ---- [".*Personal/beyondmagic.space/source/typescript/.*ts"] = function()
      ----   vim.api.nvim_command('cd ~/Programming/Personal/beyondmagic.space/')
      ----   build('ts index')
      ---- end,
      --[".*Personal/beyondmagic.space/source/html/.*html"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Personal/beyondmagic.space/')
      --  build('html')
      --end,
      --[".*Personal/beyondmagic.space/source/scss/.*"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Personal/beyondmagic.space/')
      --  build('scss')
      --end,

      ---- NWrite - WhiteDove
      ---- https://github.com/BeyondMagic/whitedove
      --[".*Projects/WhiteDove/whitedove/source/html/.*"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Projects/WhiteDove/whitedove/')
      --  build('html')
      --end,
      --[".*Projects/WhiteDove/whitedove/source/scss/.*"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Projects/WhiteDove/whitedove/')
      --  build('scss')
      --end,
      --[".*Projects/WhiteDove/whitedove/source/ts/.*"] = function()
      --  vim.api.nvim_command('cd ~/Programming/Projects/WhiteDove/whitedove/')
      --  build('ts index')
      --end,

      ---- Story :)
      --[".*Story/Script/.*"] = function()
      --  vim.api.nvim_command('cd ~/Story/Script/')
      --  vim.api.nvim_command('set colorcolumn=85')
      --  vim.api.nvim_command('set textwidth=84')
      --  vim.api.nvim_set_keymap('i', '<Up>', '<Up>',     { noremap = true, silent = true  })
      --  vim.api.nvim_set_keymap('i', '<Down>', '<Down>', { noremap = true, silent = true  })
      --  return 'txt'
      --end,
    },

    filename = {

      -- For eslint_d configuration file.
      ['.eslintrc'] = 'jsonc',

      -- For Typescript projects.
      --['tsconfig.json'] = 'json5',

      -- Those template files work with the system to auto-update certain configuration of programs.
      ['zathurarc.template'] = function()
        vim.api.nvim_command('cd ~/.config/zathura/')

        -- Make up the zathurarc.
        vim.api.nvim_create_autocmd( 'BufWritePost', {
          pattern = '<buffer>',
          callback = function ()
            os.execute( [[zsh -c ". ~/.config/zsh/aliasesrc; up_zathura"]] )
          end,
        })

        return 'python'
      end,

      -- To work within the folder plus LSP.
      aliasesrc = function()
        vim.api.nvim_command('cd ~/.config/zsh/')
        return 'sh'
      end,

      -- To restart xsettingsd
      xsettingsdrc = gtk_build,

      -- https://github.com/kovetskiy/sxhkd-vim
      sxhkdrc = function()
      vim.api.nvim_create_autocmd( 'BufWritePost', {
        pattern = '<buffer>',
        callback = function ()
          job('pkill -USR1 -x sxhkd')
        end,
      })

        return 'sxhkd'
      end,
	  },
})
