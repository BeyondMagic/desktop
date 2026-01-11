---@diagnostic disable: undefined-global

local M = {}

local registered = false

function M.setup()
	if registered then
		return
	end

	registered = true

	local cd_file = vim.env.NEOVIM_CD or '/tmp/nvim_cd_path'

	vim.api.nvim_create_autocmd('VimLeave', {
		pattern = '*',
		desc = 'Write current directory to a temp file on exit',
		callback = function()
			if not (cd_file and cd_file ~= '') then
				return
			end

			vim.fn.writefile({ vim.fn.getcwd() }, cd_file)
		end,
	})
end

return M
