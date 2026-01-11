--[[
    Old text                    Command         New text
--------------------------------------------------------------------------------
    surround_words              ysiw)           (surround_words)
    make strings               ys$"            "make strings"
    [delete ar*ound me!]        ds]             delete around me!
    "change quot*es"            cs'"            "change quotes"
    <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
    delete(functi*on calls)     dsf             function calls
]]

return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration here, or leave empty to use defaults
    })
  end
}
