-- Scrollbar and minimap

return {
  "petertriho/nvim-scrollbar",
  opts = {
    exclude = {
      filetypes = { ["neo-tree"] = true },
    },
    providers = {
      cursor = true,
      diagnostic = true,
      search = true,
      marks = true,
      gitsigns = true,
    },
    scrollbar = {
      visibility = "active",
      unit = "screenline",
      thumb = {
        text = " ",
        hide_if_all_visible = true,
      },
    },
    minimap = {
      enabled = false,
      visibility = "active",
    },
  },
}
