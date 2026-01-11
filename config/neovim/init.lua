-- Main theme of Neovim.
require 'theme'

-- Personal Keymaps of neovim:
require 'keymappings'

-- Filetype specialties.
require 'filetype'

-- Global, windows options of neovim:
require 'options'

-- To adminstrate packages:
require 'plugin-manager'

-- Autocmd
require 'autocmd'

-- LSP for editing.
require 'lsp'

local function get_groups_linked_to_nontext()
	local all_groups = vim.fn.getcompletion('', 'highlight')
	local cache = {}

	local function links_to_nontext(group, seen)
		if cache[group] ~= nil then
			return cache[group]
		end
		seen = seen or {}
		if seen[group] then
			cache[group] = false
			return false
		end
		seen[group] = true

		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = true })
		local result = false
		if ok and type(hl) == 'table' then
			if hl.link == 'NonText' then
				result = true
			elseif type(hl.link) == 'string' then
				result = links_to_nontext(hl.link, seen)
			end
		end

		seen[group] = nil
		cache[group] = result
		return result
	end

	local linked = {}
	for _, group in ipairs(all_groups) do
		if links_to_nontext(group) then
			table.insert(linked, group)
		end
	end
	return linked
end

local function show_nontext_links()
	local groups = get_groups_linked_to_nontext()
	if vim.tbl_isempty(groups) then
		vim.notify('No highlight groups linked to NonText', vim.log.levels.INFO)
		return
	end

	local lines = { 'Highlight groups linked to NonText:' }
	vim.list_extend(lines, groups)

	vim.cmd('botright new')
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'wipe'
	vim.bo[buf].swapfile = false
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.keymap.set('n', 'q', '<cmd>bd!<CR>', { buffer = buf, silent = true, nowait = true })
end

vim.api.nvim_create_user_command('ShowNonTextLinks', show_nontext_links, {})
