-- To install lazy.nvim automatically.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- Plugins start here, source from Packer:
require('lazy').setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	-- Configure lazy.nvim settings here
	rocks = {
		enabled = false, -- Ensure rocks support is generally enabled if needed
		hererocks = false, -- This is the line you need to add/change
	},
	-- other configuration like install, checker etc
})
