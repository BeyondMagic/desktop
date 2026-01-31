local root = COLOURSCHEME_ACCESS .. '.highlights.groups.'
local colourscheme = require(COLOURSCHEME_ACCESS)

function read(file_names)
  for _, name in pairs(file_names) do
    colourscheme.highlight_all(require(root .. name))
  end
end

read {
  --[[ Default highlights of n/vim. ]]
  'defaults',

  --[[ Editor UI ]]
  'editor-ui',

  --[[ Extra stuff for other highlights ]]
  'extra',

  --[[ Programming Languages
		Everything in this section is OPTIONAL. Feel free to remove everything
		here if you don't want to define it, or add more if there's something
		missing. ]]
  'filetypes.c++',
  'filetypes.coq',
  'filetypes.crontab',
  'filetypes.cs',
  'filetypes.css',
  'filetypes.dart',
  'filetypes.dosini',
  'filetypes.dot',
  'filetypes.git',
  'filetypes.go',
  'filetypes.help',
  'filetypes.html',
  'filetypes.i3config',
  'filetypes.java',
  'filetypes.javascript',
  'filetypes.json',
  'filetypes.lua',
  'filetypes.make',
  'filetypes.man',
  'filetypes.markdown',
  'filetypes.plantuml',
  'filetypes.python',
  'filetypes.razor',
  'filetypes.ruby',
  'filetypes.rust',
  'filetypes.scala',
  'filetypes.scss',
  'filetypes.shell',
  'filetypes.solidity',
  'filetypes.sql',
  'filetypes.tex',
  'filetypes.toml',
  'filetypes.vimscript',
  'filetypes.xml',
  'filetypes.xxd',
  'filetypes.yaml',

  --[[ Plugins
		Everything in this section is OPTIONAL. Feel free to remove everything
		here if you don't want to define it, or add more if there's something
		missing. ]]
  'plugins.ale',
  'plugins.barbar-nvim',
  'plugins.barbecue-nvim',
  'plugins.coc-nvim',
  'plugins.fern',
  'plugins.gitsigns-nvim',
  'plugins.indent-blankline-nvim',
  'plugins.lazy-nvim',
  'plugins.lsp',
  'plugins.lspsaga-nvim',
  'plugins.mini-nvim',
  'plugins.neo-tree',
  'plugins.nerdtree',
  'plugins.nvim-cmp',
  'plugins.nvim-tree',
  'plugins.nvim-ts-rainbow2',
  'plugins.packer',
  'plugins.symbols-outline',
  'plugins.telescope-nvim',
  'plugins.todo-comments',
  'plugins.treesitter',
  'plugins.vim-easymotion',
  'plugins.vim-gitgutter',
  'plugins.vim-illuminate',
  'plugins.vim-indent-guides',
  'plugins.vim-jumpmotion',
  'plugins.vim-sandwhich',
  'plugins.vim-signify',
  'plugins.blink-cmp',
  'plugins.sidekick'

}
