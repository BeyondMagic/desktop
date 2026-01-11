---@diagnostic disable: undefined-global

local M = {}

local LONG_LINE_THRESHOLD = 20000
local registered = false
local settings_initialised = false

local default_settings = {
	size_limit = 4 * 1024 * 1024,
	buffer_options = {
		swapfile = false,
		bufhidden = 'unload',
		buftype = 'nowrite',
		undolevels = -1,
	},
	on_large_file_read_pre = function(_) end,
}

local settings = {}
local large_file_group = vim.api.nvim_create_augroup('LargeFileAutocmds', { clear = false })
local old_eventignore = ''

local function disable_highlight_on_long_lines(event)
	local bufnr = event.buf

	if vim.api.nvim_buf_get_option(bufnr, 'buftype') ~= '' then
		return
	end

	if vim.b[bufnr].__long_line_highlight_checked then
		return
	end

	vim.b[bufnr].__long_line_highlight_checked = true

	local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''

	if #first_line < LONG_LINE_THRESHOLD then
		return
	end

	vim.api.nvim_set_option_value('syntax', 'OFF', { buf = bufnr })
	pcall(vim.treesitter.stop, bufnr)
	vim.b[bufnr].__long_line_highlight_disabled = true
end

local function buf_read_pre(event)
	if not event.file then
		return
	end

	local ok, stat = pcall(vim.loop.fs_stat, event.file)

	if not (ok and stat and stat.size and stat.size > settings.size_limit) then
		return
	end

	old_eventignore = vim.o.eventignore
	vim.b[event.buf].is_large_file = true
	vim.o.eventignore = 'FileType'

	for option, value in pairs(settings.buffer_options) do
		vim.bo[event.buf][option] = value
	end

	settings.on_large_file_read_pre(event)

	if vim.lsp and vim.lsp.stop_client and vim.lsp.get_clients then
		local clients = vim.lsp.get_clients({ bufnr = event.buf })
		if clients and next(clients) then
			vim.b[event.buf].__large_file_lsp_disabled = true
			vim.lsp.stop_client(0)
		end
	end
end

local function buf_win_enter(event)
	if old_eventignore ~= '' then
		vim.o.eventignore = old_eventignore
		old_eventignore = ''
	end

	if vim.b[event.buf].is_large_file then
		vim.wo.wrap = false
	else
		vim.wo.wrap = vim.o.wrap
	end
end

local function buf_enter(event)
	if vim.b[event.buf].is_large_file then
		if vim.g.loaded_matchparen then
			vim.cmd('NoMatchParen')
		end
	else
		if not vim.g.loaded_matchparen then
			vim.cmd('DoMatchParen')
		end
	end
end

local function ensure_settings(opts)
	if settings_initialised then
		return
	end

	settings_initialised = true
	opts = opts or {}

	for _, key in ipairs({ 'size_limit', 'buffer_options', 'on_large_file_read_pre' }) do
		if opts[key] == nil then
			settings[key] = default_settings[key]
		else
			settings[key] = opts[key]
		end
	end
end

function M.setup()
	if registered then
		return
	end

	registered = true
	ensure_settings()

	vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
		desc = 'Disable syntax highlighting when any line exceeds the long-line threshold',
		callback = disable_highlight_on_long_lines,
	})

	vim.api.nvim_create_autocmd('BufReadPre', {
		group = large_file_group,
		callback = buf_read_pre,
	})

	vim.api.nvim_create_autocmd('BufWinEnter', {
		group = large_file_group,
		callback = buf_win_enter,
	})

	vim.api.nvim_create_autocmd('BufEnter', {
		group = large_file_group,
		callback = buf_enter,
	})
end

return M
