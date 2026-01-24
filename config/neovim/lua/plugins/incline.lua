return {
  'b0o/incline.nvim',
  opts = {
    debounce_threshold = {
      falling = 50,
      rising = 0
    },
    hide = {
      cursorline = true,
      focused_win = false,
      only_win = true
    },
    highlight = {
      groups = {
        InclineNormal = {
          default = true,
          group = "NormalFloat"
        },
        InclineNormalNC = {
          default = true,
          group = "NormalFloat"
        }
      }
    },
    ignore = {
      buftypes = "special",
      filetypes = {},
      floating_wins = true,
      unlisted_buffers = true,
      wintypes = "special"
    },
    render = "basic",
    window = {
      margin = {
        horizontal = 1,
        vertical = 1
      },
      options = {
        signcolumn = "no",
        wrap = false
      },
      padding = 1,
      padding_char = " ",
      placement = {
        horizontal = "right",
        vertical = "top"
      },
      width = "fit",
      winhighlight = {
        active = {
          EndOfBuffer = "None",
          Normal = "InclineNormal",
          Search = "None"
        },
        inactive = {
          EndOfBuffer = "None",
          Normal = "InclineNormalNC",
          Search = "None"
        }
      },
      zindex = 10
    }
  }
}
