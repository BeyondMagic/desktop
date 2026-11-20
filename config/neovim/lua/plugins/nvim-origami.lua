return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {
		foldKeymaps = {
			setup = false,
		},
	}, -- needed even when using default config

	-- recommended: disable vim's auto-folding
	init = function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99

		-- vim.keymap.set("n", "h", function() require("origami").h() end)
		-- vim.keymap.set("n", "l", function() require("origami").l() end)
		-- vim.keymap.set("n", "^", function() require("origami").caret() end)
		-- vim.keymap.set("n", "$", function() require("origami").dollar() end)
	end,
}
