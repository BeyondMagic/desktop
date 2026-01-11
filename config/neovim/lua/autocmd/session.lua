---@diagnostic disable: undefined-global

local M = {}

local registered = false

function M.setup()
	if registered then
		return
	end

	registered = true

	vim.api.nvim_create_autocmd('VimLeavePre', {
		pattern = '*',
		desc = 'Save session on exit',
		command = ':mks! ~/.config/nvim/session.vim',
	})
end

return M
