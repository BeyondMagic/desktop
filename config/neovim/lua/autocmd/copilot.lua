local M = {}

function M.setup()
	print("Setting up Copilot autocmds...")
	vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
		desc = 'Disable Copilot for all filetypes',
		pattern = { '*' },
		callback = function()
			vim.g.copilot = false
			vim.cmd(":Copilot disable")
		end
	})
end

return M
