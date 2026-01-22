return {
	'saghen/blink.cmp',
	-- optional: provides snippets for the snippet source
	dependencies = { 'rafamadriz/friendly-snippets',
		"fang2hou/blink-copilot", },

	-- use a release tag to download pre-built binaries
	version = '1.*',
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		completion = {
			-- Show suggestions after typing a keyword character (default: true)
			-- Set to false to avoid showing after typing the *first* char of a word
			-- show_on_trigger_character = true, -- Set to true to show on trigger chars
			-- Or enable prefetching when entering insert mode to show suggestions immediately
			trigger = {
				show_on_backspace = true,
				prefetch_on_insert = true, -- Shows completions on InsertEnter event
				-- show_on_keyword = true,
				-- Show suggestions after typing specific trigger characters (e.g., '.', '(', ':', etc.)

				-- When true, will show the completion window after entering insert mode
				show_on_insert = false,

			},
			-- Other settings for documentation, menu, etc.
			documentation = {
				auto_show = true, -- Show docs with suggestions
				auto_show_delay_ms = 200,
			},
			menu = {
				auto_show = true, -- Show the menu automatically
			},
		},

		-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
		-- 'super-tab' for mappings similar to vscode (tab to accept)
		-- 'enter' for enter to accept
		-- 'none' for no mappings
		--
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		--
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = {
			preset = 'default',
			["<Tab>"] = {
				"select_next",
				"snippet_forward",
				"fallback",
			},
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = 'mono'
		},


		sources = {
			default = {
				"copilot",
				"lsp",
				"buffer",
				"snippets",
				"path"
			},
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					score_offset = 100,
					async = true,
				},
			},
		},


		-- (Default) Only show the documentation popup when manually triggered


		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = { implementation = "prefer_rust_with_warning" }
	},
	opts_extend = { "sources.default" },
	config = function(_, opts)
		local blink = require('blink.cmp')
		blink.setup(opts)

		--local function del_keymap_if_exists(mode, lhs)
		--  -- Only attempt to delete the mapping if it actually exists, so we don't
		--  -- mask unexpected errors with pcall.
		--  if vim.fn.maparg(lhs, mode) == '' then
		--    return
		--  end
		--  vim.keymap.del(mode, lhs)
		--end

		-- Keep normal-mode tab navigation for Cokeline, even if other plugins remap it.
		-- local function set_cokeline_tabs()
		--   del_keymap_if_exists('n', '<Tab>')
		--   del_keymap_if_exists('n', '<S-Tab>')
		--   vim.keymap.set('n', '<Tab>', '<Plug>(cokeline-focus-next)', { silent = true })
		--   vim.keymap.set('n', '<S-Tab>', '<Plug>(cokeline-focus-prev)', { silent = true })
		-- end

		-- set_cokeline_tabs()
		-- vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
		--   callback = set_cokeline_tabs,
		--   desc = 'Ensure Cokeline keeps normal-mode <Tab>/<S-Tab> after other mappings run',
		-- })
	end
}
