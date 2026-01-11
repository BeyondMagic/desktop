return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	dependencies = {
		"copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
	},
	config = function()
		require("copilot").setup({
			panel = {
				enabled = false,
				auto_refresh = false,
				keymap = {
					jump_prev = "[[",
					jump_next = "]]",
					accept = "<CR>",
					refresh = "gr",
					open = "<M-CR>"
				},
				layout = {
					position = "bottom", -- | top | left | right | horizontal | vertical
					ratio = 0.4
				},
			},
			suggestion = {
				enabled = false,
				auto_trigger = false,
				hide_during_completion = true,
				debounce = 75,
				keymap = {
					accept = "<C-l>",
					accept_word = false,
					accept_line = false,
					next = "<C-k>",
					prev = "<C-j>",
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				["*"] = true,
				["."] = true,
				-- yaml = false,
				-- help = false,
				-- gitcommit = false,
				-- gitrebase = false,
				-- hgcommit = false,
				-- svn = false,
				-- cvs = false,

				lua = true,
				markdown = true,
				javascript = true,
				typescript = true,
				rust = true,
				c = true,
				["c#"] = true,
				["c++"] = true,
				go = true,
				python = true,
				json = true,
			},
			copilot_node_command = 'node', -- Node.js version must be > 18.x
			server_opts_overrides = {},
		})
	end,
}
