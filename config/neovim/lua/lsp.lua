-- Defined in init.lua
vim.lsp.config('*', {
	capabilities = {
		textDocument = {
			semanticTokens = {
				multilineTokenSupport = true,
			}
		}
	},
	root_markers = { '.git' },
})

-- LSP Lua (build from source without telemetry (use grep to find config)
require 'lsp.lua'

-- Latex
-- require 'lsp.latex'

-- C++ and C
require 'lsp.c_c++'

-- Rust
-- require 'lsp.rust'

-- JSON
require 'lsp.json'

-- Javascript + Typescript
require 'lsp.javascript'

-- Bash Language Server
-- require 'lsp.bash'

-- CSS + Less + SCSS
require 'lsp.css'

-- HTML
require 'lsp.html'

-- Python
require 'lsp.python'

-- zig
-- require 'lsp.zig'

-- typst
require 'lsp.typst'

-- nushell
require 'lsp.nushell'

-- eslint_d + prettierd
-- require 'lsp.eslint_d_prettierd'

-- typescript + javascript + json
require 'lsp.biome'

-- elixir
-- require 'lsp.elixir'

-- copilot
require 'lsp.copilot'

-- dbml
-- Disabled for now, as dbml-lsp is not yet stable, nor maintained.
-- require 'lsp.dbml'
