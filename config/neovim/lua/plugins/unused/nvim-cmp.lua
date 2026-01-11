-- Completion menu.

-- Icons to display.
local icons = {
	Text          = "  ",
	Method        = "  ",
	Function      = "  ",
	Constructor   = "  ",
	Field         = " ﰠ ",
	Variable      = "  ",
	Class         = " ﴯ ",
	Interface     = "  ",
	Module        = "  ",
	Property      = " ﰠ ",
	Unit          = " 塞 ",
	Value         = "  ",
	Enum          = "  ",
	Keyword       = "  ",
	Snippet       = "  ",
	Color         = "  ",
	File          = "  ",
	Reference     = "  ",
	Folder        = "  ",
	EnumMember    = "  ",
	Constant      = "  ",
	Struct        = " פּ ",
	Event         = "  ",
	Operator      = "  ",
	TypeParameter = " T ",
	Book          = "  "
}

-- Load specialities from LuaSnip.
-- Set it with VSCode-like mode.
--require("luasnip").config.set_config({
--  history      = true,
--  updateevents = "TextChanged,TextChangedI"
--})

-- Load loaders from VSCode.
--require("luasnip.loaders.from_vscode").lazy_load({
--  paths = { "~/.local/share/lazy/friendly-snippets" }
--})

local has_words_before = function()
	if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then return false end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

return {
	'hrsh7th/nvim-cmp',
	dependencies = {
		{ "octaltree/cmp-look" },
		--
		{ "hrsh7th/cmp-nvim-lsp" },
		--
		{ "hrsh7th/cmp-nvim-lua" },
		-- Buffer words.
		{ "hrsh7th/cmp-buffer" },
		-- Path autocompletion.
		{ "hrsh7th/cmp-path" },
		--
		{ "hrsh7th/cmp-cmdline" },
		--
		{ "saadparwaiz1/cmp_luasnip" },
		--
		{ "hrsh7th/vim-vsnip" },
		--
		{ "rafamadriz/friendly-snippets" },
		-- Snippets for lua.
		{ "L3MON4D3/LuaSnip", }, --config = "luasnip" },
		--
		{ "hrsh7th/cmp-vsnip" },
		--
		-- Signature for functions.
		--{ 'hrsh7th/cmp-nvim-lsp-signature-help' },
		--
		{ "hrsh7th/vim-vsnip-integ" },
		-- Make arimathetic operations.
		{ "hrsh7th/cmp-calc" },
		-- Emoji.
		{ "hrsh7th/cmp-emoji" },
	},
	config = function()
		local cmp = require 'cmp'

		local luasnip = require 'luasnip'

		cmp.setup {

			-- Window documentation, for defining its dimensions.
			window = {
				-- Max 10 items on display for documentation.
				max_height = 10,
				completion = {
					side_padding = 0,
					col_offset = 1,
				},
			},

			-- Snippet support.
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			-- How the match works based on the input.
			matching = {
				-- Whethever we allow fuzzy matching or not.
				disallow_fuzzy_matching = false,
			},

			-- Mapping each keybind.
			mapping = {
				["<C-d>"]   = cmp.mapping.scroll_docs(-4),
				["<C-f>"]   = cmp.mapping.scroll_docs(4),
				--["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"]   = cmp.mapping.close(),
				["<CR>"]    = cmp.mapping.confirm {
					behavior = cmp.ConfirmBehavior.Replace,
					select   = true,
				},
				["<Tab>"]   = vim.schedule_wrap(function(fallback)
					if require("sidekick").nes_jump_or_apply() then
						return -- jumped or applied
					elseif cmp.visible() and has_words_before() then
						cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
					else
						fallback()
					end
				end),
				-- ["<Tab>"] = function(fallback)
				-- 	if cmp.visible() then
				-- 		cmp.select_next_item()
				-- 	elseif luasnip.expand_or_jumpable() then
				-- 		luasnip.expand_or_jump()
				-- 		-- vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
				-- 	-- elseif copilot_keys ~= '' and type(copilot_keys) == 'string' then
				-- 	-- 	vim.api.nvim_feedkeys(copilot_keys, 'i', true)
				-- 	else
				-- 		fallback()
				-- 	end
				-- end,
				["<S-Tab>"] = function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
						-- vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
					else
						fallback()
					end
				end,
			},

			-- Formatting the menu display.
			formatting = {
				fields = { 'kind', 'abbr', 'menu' },
				format = function(entry, vim_item)
					vim_item.menu = vim_item.kind

					-- load lspkind icons
					--vim_item.kind = string.format(
					--  "%s %s",
					--  icons[vim_item.kind],
					--  vim_item.kind
					--)
					vim_item.kind = icons[vim_item.kind]

					--vim_item.menu = string.format(
					--  "%s %s",
					--  ({
					--      nvim_lsp = "力",
					--      nvim_lua = "",
					--      luasnip  = icons.Color,
					--      path     = "﫶",
					--      buffer   = "﬘ ",
					--      look     = icons.Book,
					--      emoji    = "😎",
					--  })[entry.source.name],
					--  name
					--)

					return vim_item
				end,
			},

			-- Experimental features.
			experimental = {

				-- It will type a shadow text of the intended completion.
				ghost_text = { hl_group = 'Comment' },

			},

			-- Sources for completion, since it is modular; cmp accepts
			-- Multiple modules.
			sources = {

				-- Simple signature, normally outside an object.
				--{ name = 'nvim_lsp_signature_help', priority = 15 },

				-- More snippets.
				-- For all types of languages.
				{
					name = "friendly-snippets",
					priority = 11,
				},

				-- Copilot
				{
					name = "copilot",
					group_index = 2
				},

				-- For the Nvim lua specifics commands.
				{
					name = "nvim_lua",
					priority = 8,
				},

				-- Support with the current active LSP.
				-- Anything that LSP supports and can share with CMP.
				{
					name = "nvim_lsp",
					priority = 11,
					--max_item_count = 10,
				},

				-- Snippets in general to facilitate life.
				-- Type a often typed methods, like for in C.
				{
					name = "luasnip",
					priority = 6
				},

				-- Show path based on the backslashes.
				-- Type any path, relatively or globally.
				{
					name = "path",
					priority = 9,
				},

				-- Words from buffer.
				{
					name = "buffer",
					priority = 4,
				},

				-- Max item count.
				{
					name = 'calc',
					priority = 10,
				}
			}
		}
	end
}
