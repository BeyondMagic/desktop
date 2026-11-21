-- João Farias © BeyondMagic <beyondmagic@mail.ru> 2024-2026

---@diagnostic disable: undefined-global

local M = {}

M.MAX_SESSIONS = 25

local uv = vim.uv or vim.loop

local state = {
	registered = false,
	started_on_alpha = false,
	left_alpha = false,
	migrated = false,
}

--- Return the canonical directory where managed session files live.
--- @return string
function M.sessions_dir()
	return vim.fn.stdpath('state') .. '/sessions'
end

--- Normalize a directory or file path without resolving symlinks unexpectedly.
--- @param path string
--- @return string
local function normalize_path(path)
	local expanded = vim.fn.fnamemodify(path, ':p'):gsub('/+$', '')
	if expanded == '' then
		return '/'
	end
	return expanded
end

--- Shorten $HOME prefix to `~` for display.
--- @param path string
--- @return string
local function shorten_home(path)
	local home = vim.env.HOME
	if not home or home == '' then
		return path
	end
	home = home:gsub('/+$', '')
	if path == home then
		return '~'
	end
	if path:sub(1, #home + 1) == home .. '/' then
		return '~' .. path:sub(#home + 1)
	end
	return path
end

--- Compute the metadata JSON path paired with a `.vim` session file.
--- @param session_path string
--- @return string
local function meta_path_for(session_path)
	return (session_path:gsub('%.vim$', '.meta.json'))
end

--- Derive a readable, collision-free session stem from a working directory path.
--- @param cwd string
--- @return string
local function cwd_to_stem(cwd)
	local clean = normalize_path(cwd)
	local tail = clean == '/' and 'root' or vim.fn.fnamemodify(clean, ':t')
	local slug = tail:gsub('[^%w%._%-]', '_'):gsub('^_+', ''):gsub('_+$', '')
	if slug == '' then
		slug = 'session'
	end
	if #slug > 32 then
		slug = slug:sub(1, 32)
	end
	local hash = vim.fn.sha256(clean):sub(1, 12)
	return slug .. '-' .. hash
end

--- Check whether a session path belongs to the managed sessions directory.
--- @param path string|nil
--- @return boolean
local function is_managed_session(path)
	if not path or path == '' or path:sub(-4) ~= '.vim' then
		return false
	end
	local dir = normalize_path(M.sessions_dir())
	local target = normalize_path(path)
	return target:sub(1, #dir + 1) == dir .. '/'
end

--- Return true when a buffer represents a real workspace file or terminal.
--- Empty `[No Name]` buffers, directories, and UI/picker buffers return false.
--- @param buf number
--- @return boolean
local function is_real_buffer(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return false
	end
	if not vim.bo[buf].buflisted then
		return false
	end
	if vim.bo[buf].filetype == 'alpha' then
		return false
	end
	local bt = vim.bo[buf].buftype
	if bt == 'terminal' then
		return true
	end
	if bt ~= '' then
		return false
	end
	local name = vim.api.nvim_buf_get_name(buf)
	if name == '' then
		return false
	end
	return vim.fn.isdirectory(name) == 0
end

--- Collect all real listed buffers in the current Neovim instance.
--- @return string[] files
--- @return string active_file
local function collect_real_buffers()
	local files = {}
	local seen = {}
	local cur_buf = vim.api.nvim_get_current_buf()
	local active_file = ''

	local function record(buf)
		if not is_real_buffer(buf) then
			return
		end
		local name = vim.api.nvim_buf_get_name(buf)
		local entry = vim.bo[buf].buftype == 'terminal' and name or vim.fn.fnamemodify(name, ':p')
		if entry ~= '' and not seen[entry] then
			seen[entry] = true
			table.insert(files, entry)
		end
		if buf == cur_buf then
			active_file = entry
		end
	end

	record(cur_buf)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= cur_buf then
			record(buf)
		end
	end

	if active_file == '' and #files > 0 then
		active_file = files[1]
	end

	return files, active_file
end

--- Wipe any lingering Alpha dashboard buffers so `:mks!` does not save phantom tabs.
local function wipe_alpha_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'alpha' then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end

--- Decode a JSON file safely, returning nil on error or missing file.
--- @param path string
--- @return table|nil
local function read_json(path)
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	local lines = vim.fn.readfile(path)
	if not lines or #lines == 0 then
		return nil
	end
	local ok, data = pcall(vim.json.decode, table.concat(lines, '\n'))
	if ok and type(data) == 'table' then
		return data
	end
	return nil
end

--- Encode and write a table to JSON on disk.
--- @param path string
--- @param tbl table
local function write_json(path, tbl)
	local ok, encoded = pcall(vim.json.encode, tbl)
	if ok and type(encoded) == 'string' then
		vim.fn.writefile({ encoded }, path)
	end
end

--- Unescape Vimscript `fnameescape`-style spaces and expand leading `~`.
--- @param raw string
--- @return string
local function unescape_vim_path(raw)
	local unescaped = raw:gsub('\\(.)', '%1')
	if unescaped == '~' or unescaped:sub(1, 2) == '~/' then
		unescaped = vim.fn.expand(unescaped)
	end
	return unescaped
end

--- Parse fallback metadata directly from a `.vim` session script when `.meta.json` is absent.
--- @param vim_path string
--- @return table
local function parse_vim_fallback(vim_path)
	local stat = uv.fs_stat(vim_path)
	local mtime = stat and stat.mtime and stat.mtime.sec or os.time()
	local cwd = vim.fn.expand('~')
	local files = {}
	local seen = {}
	local active_file = ''

	local function resolve_entry(raw)
		local p = unescape_vim_path(vim.trim(raw))
		if p == '' then
			return ''
		end
		if p:sub(1, 1) ~= '/' and not p:match('^%w+://') then
			p = normalize_path(cwd .. '/' .. p)
		end
		return p
	end

	if vim.fn.filereadable(vim_path) == 1 then
		for _, line in ipairs(vim.fn.readfile(vim_path)) do
			local cd_arg = line:match('^cd%s+(.+)$')
			if cd_arg then
				cwd = normalize_path(unescape_vim_path(vim.trim(cd_arg)))
			else
				local badd_arg = line:match('^badd%s+%+?%d*%s+(.+)$')
				if badd_arg then
					local p = resolve_entry(badd_arg)
					if p ~= '' and not seen[p] then
						seen[p] = true
						table.insert(files, p)
					end
				else
					local edit_arg = line:match('^edit%s+(.+)$')
					if edit_arg then
						local p = resolve_entry(edit_arg)
						if p ~= '' then
							active_file = p
							if not seen[p] then
								seen[p] = true
								table.insert(files, p)
							end
						end
					end
				end
			end
		end
	end

	if active_file == '' and #files > 0 then
		active_file = files[1]
	end

	return {
		version = 1,
		session = normalize_path(vim_path),
		cwd = cwd,
		updated_at = mtime,
		mtime = mtime,
		active_file = active_file,
		files = files,
	}
end

--- Migrate the legacy single `~/.config/nvim/session.vim` file once when the store is empty.
local function migrate_legacy_session()
	if state.migrated then
		return
	end
	state.migrated = true

	local dir = M.sessions_dir()
	vim.fn.mkdir(dir, 'p')

	local existing = vim.fn.globpath(dir, '*.vim', false, true)
	if #existing > 0 then
		return
	end

	local legacy = vim.fn.expand('~/.config/nvim/session.vim')
	if vim.fn.filereadable(legacy) == 0 then
		return
	end

	local meta = parse_vim_fallback(legacy)
	if #meta.files == 0 then
		return
	end

	local dest = dir .. '/' .. cwd_to_stem(meta.cwd) .. '.vim'
	local ok_lines, lines = pcall(vim.fn.readfile, legacy, 'b')
	if not ok_lines or not lines then
		return
	end

	local wrote = pcall(vim.fn.writefile, lines, dest, 'b')
	if wrote then
		meta.session = dest
		write_json(meta_path_for(dest), meta)
		pcall(uv.fs_unlink, legacy)
	end
end

--- Load metadata for a single managed `.vim` file.
--- @param vim_path string
--- @return table
local function read_entry(vim_path)
	local norm_vim = normalize_path(vim_path)
	local stat = uv.fs_stat(norm_vim)
	local mtime = stat and stat.mtime and stat.mtime.sec or 0
	local mtime_nsec = stat and stat.mtime and stat.mtime.nsec or 0
	local meta = read_json(meta_path_for(norm_vim))

	if not meta then
		meta = parse_vim_fallback(norm_vim)
	else
		meta.session = norm_vim
		meta.cwd = meta.cwd and normalize_path(meta.cwd) or vim.fn.expand('~')
		meta.files = type(meta.files) == 'table' and meta.files or {}
		meta.active_file = type(meta.active_file) == 'string' and meta.active_file or (meta.files[1] or '')
		meta.updated_at = tonumber(meta.updated_at) or mtime
	end

	meta.mtime = mtime
	meta.mtime_nsec = mtime_nsec
	return meta
end

--- Return all valid managed sessions sorted newest-first without capping.
--- @return table[]
local function scan_all_sessions()
	local dir = M.sessions_dir()
	if vim.fn.isdirectory(dir) == 0 then
		return {}
	end

	local vim_files = vim.fn.globpath(dir, '*.vim', false, true)
	local entries = {}
	for _, path in ipairs(vim_files) do
		table.insert(entries, read_entry(path))
	end

	table.sort(entries, function(a, b)
		if a.updated_at ~= b.updated_at then
			return a.updated_at > b.updated_at
		end
		if a.mtime ~= b.mtime then
			return a.mtime > b.mtime
		end
		if a.mtime_nsec ~= b.mtime_nsec then
			return a.mtime_nsec > b.mtime_nsec
		end
		return a.session < b.session
	end)

	return entries
end

--- Remove sessions past MAX_SESSIONS and clean up orphaned `.meta.json` files.
local function prune_sessions()
	local dir = M.sessions_dir()
	local entries = scan_all_sessions()
	for i = M.MAX_SESSIONS + 1, #entries do
		pcall(uv.fs_unlink, entries[i].session)
		pcall(uv.fs_unlink, meta_path_for(entries[i].session))
	end

	local valid_stems = {}
	for i = 1, math.min(#entries, M.MAX_SESSIONS) do
		valid_stems[meta_path_for(entries[i].session)] = true
	end

	for _, meta_path in ipairs(vim.fn.globpath(dir, '*.meta.json', false, true)) do
		local norm_meta = normalize_path(meta_path)
		if not valid_stems[norm_meta] then
			pcall(uv.fs_unlink, norm_meta)
		end
	end
end

--- List up to MAX_SESSIONS saved sessions ordered from most recent to oldest.
--- @return table[]
function M.list()
	migrate_legacy_session()
	local entries = scan_all_sessions()
	if #entries > M.MAX_SESSIONS then
		local trimmed = {}
		for i = 1, M.MAX_SESSIONS do
			trimmed[i] = entries[i]
		end
		return trimmed
	end
	return entries
end

--- Save the current Neovim session unless the user never left Alpha without real buffers.
--- Overwrites restored managed sessions in-place or keys fresh runs by normalized CWD hash.
--- @return boolean saved
function M.save()
	local files, active_file = collect_real_buffers()
	if state.started_on_alpha and not state.left_alpha then
		return false
	end
	if #files == 0 then
		return false
	end

	migrate_legacy_session()

	local dir = M.sessions_dir()
	vim.fn.mkdir(dir, 'p')

	local cwd = normalize_path(vim.fn.getcwd())
	local target_vim
	if is_managed_session(vim.v.this_session) then
		target_vim = normalize_path(vim.v.this_session)
	else
		target_vim = dir .. '/' .. cwd_to_stem(cwd) .. '.vim'
	end

	wipe_alpha_buffers()

	local ok = pcall(vim.cmd, 'silent! mksession! ' .. vim.fn.fnameescape(target_vim))
	if not ok then
		return false
	end

	write_json(meta_path_for(target_vim), {
		version = 1,
		session = target_vim,
		cwd = cwd,
		updated_at = os.time(),
		active_file = active_file,
		files = files,
	})

	prune_sessions()
	return true
end

--- Delete a session `.vim` file and its companion `.meta.json` from history.
--- @param session_path string
--- @return boolean deleted
function M.delete(session_path)
	if not session_path or session_path == '' then
		return false
	end
	local norm = normalize_path(session_path)
	local ok_vim = pcall(uv.fs_unlink, norm)
	pcall(uv.fs_unlink, meta_path_for(norm))
	return ok_vim
end

--- Restore a saved session inside the current Neovim instance and mark it active.
--- @param session_path string
--- @return boolean restored
function M.restore(session_path)
	if not session_path or session_path == '' or vim.fn.filereadable(session_path) == 0 then
		vim.notify('Session file not found: ' .. tostring(session_path), vim.log.levels.WARN)
		return false
	end

	local alpha_bufs = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'alpha' then
			table.insert(alpha_bufs, buf)
		end
	end

	local ok, err = pcall(vim.cmd, 'silent source ' .. vim.fn.fnameescape(session_path))
	if not ok then
		vim.notify('Failed to restore session: ' .. tostring(err), vim.log.levels.ERROR)
		return false
	end

	if vim.v.this_session == '' then
		vim.v.this_session = normalize_path(session_path)
	end

	for _, buf in ipairs(alpha_bufs) do
		if vim.api.nvim_buf_is_valid(buf) and buf ~= vim.api.nvim_get_current_buf() then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end

	state.started_on_alpha = false
	if #collect_real_buffers() > 0 then
		state.left_alpha = true
	end

	return true
end

--- Format a compact human-readable relative age string.
--- @param ts number
--- @return string
local function format_relative_age(ts)
	local diff = math.max(0, os.time() - (ts or 0))
	if diff < 60 then
		return 'just now'
	elseif diff < 3600 then
		return string.format('%dm ago', math.floor(diff / 60))
	elseif diff < 86400 then
		return string.format('%dh ago', math.floor(diff / 3600))
	elseif diff < 86400 * 30 then
		return string.format('%dd ago', math.floor(diff / 86400))
	end
	return os.date('%Y-%m-%d', ts)
end

--- Build markdown preview lines describing a saved session.
--- @param entry table
--- @return string
local function build_preview_text(entry)
	local lines = {
		'# ' .. shorten_home(entry.cwd),
		'',
		'- **Updated:** ' .. os.date('%Y-%m-%d %H:%M:%S', entry.updated_at) .. ' (' .. format_relative_age(entry.updated_at) .. ')',
		'- **Directory:** `' .. shorten_home(entry.cwd) .. '`',
		'- **Session:** `' .. shorten_home(entry.session) .. '`',
		'',
		string.format('## Files (%d)', #entry.files),
		'',
	}

	if #entry.files == 0 then
		table.insert(lines, '_No file metadata_')
	else
		for _, f in ipairs(entry.files) do
			local label = shorten_home(f)
			if f == entry.active_file then
				table.insert(lines, string.format('- **%s** _(active)_', label))
			else
				table.insert(lines, '- ' .. label)
			end
		end
	end

	return table.concat(lines, '\n')
end

--- Build Snacks picker item descriptors for the current session list.
--- @return table[]
local function build_picker_items()
	local sessions = M.list()
	local items = {}

	for idx, entry in ipairs(sessions) do
		local cwd_short = shorten_home(entry.cwd)
		local age = format_relative_age(entry.updated_at)
		local active_name = entry.active_file ~= '' and vim.fn.fnamemodify(entry.active_file, ':t') or ''
		local file_summary = string.format('%d files', #entry.files)
		if #entry.files == 1 then
			file_summary = '1 file'
		end
		if active_name ~= '' then
			file_summary = file_summary .. ' · ' .. active_name
		end

		local search_parts = { cwd_short, age, active_name }
		for _, f in ipairs(entry.files) do
			table.insert(search_parts, shorten_home(f))
		end

		items[idx] = {
			idx = idx,
			text = table.concat(search_parts, ' '),
			session = entry.session,
			cwd = entry.cwd,
			cwd_short = cwd_short,
			age = age,
			file_summary = file_summary,
			entry = entry,
			preview = {
				text = build_preview_text(entry),
				ft = 'markdown',
				loc = false,
			},
		}
	end

	return items
end

--- Open an interactive session picker across the last MAX_SESSIONS saved sessions.
function M.pick()
	local items = build_picker_items()
	if #items == 0 then
		vim.notify('No saved sessions found.', vim.log.levels.INFO)
		return
	end

	local has_snacks, snacks = pcall(require, 'snacks')
	if has_snacks and snacks and snacks.picker then
		snacks.picker.pick({
			title = string.format('Sessions (%d/%d)', #items, M.MAX_SESSIONS),
			finder = build_picker_items,
			matcher = {
				sort_empty = false,
			},
			sort = {
				fields = { 'score:desc', 'idx' },
			},
			format = function(item)
				return {
					{ string.format('%-9s ', item.age), 'Comment' },
					{ item.cwd_short, 'Directory' },
					{ '  (' .. item.file_summary .. ')', 'SnacksPickerComment' },
				}
			end,
			preview = 'preview',
			confirm = function(picker, item)
				picker:close()
				if item and item.session then
					vim.schedule(function()
						M.restore(item.session)
					end)
				end
			end,
			actions = {
				delete_session = function(picker, item)
					if not item or not item.session then
						return
					end
					M.delete(item.session)
					if #M.list() == 0 then
						picker:close()
						vim.notify('All saved sessions deleted.', vim.log.levels.INFO)
					else
						picker:refresh()
					end
				end,
			},
			win = {
				input = {
					keys = {
						['<c-x>'] = { 'delete_session', mode = { 'i', 'n' }, desc = 'Delete session' },
						['d'] = { 'delete_session', mode = 'n', desc = 'Delete session' },
					},
				},
				list = {
					keys = {
						['<c-x>'] = { 'delete_session', desc = 'Delete session' },
						['d'] = { 'delete_session', desc = 'Delete session' },
					},
				},
			},
		})
		return
	end

	vim.ui.select(items, {
		prompt = 'Select session to restore:',
		format_item = function(item)
			return string.format('%-9s  %s  (%s)', item.age, item.cwd_short, item.file_summary)
		end,
	}, function(choice)
		if choice and choice.session then
			M.restore(choice.session)
		end
	end)
end

--- Register session lifecycle autocmds once.
function M.setup()
	if state.registered then
		return
	end
	state.registered = true

	local group = vim.api.nvim_create_augroup('UserSessionHistory', { clear = true })

	vim.api.nvim_create_autocmd('User', {
		group = group,
		pattern = 'AlphaReady',
		desc = 'Track when Neovim opens on the Alpha dashboard without restoring a session',
		callback = function()
			if vim.v.this_session == '' and #collect_real_buffers() == 0 then
				state.started_on_alpha = true
				state.left_alpha = false
			end
		end,
	})

	vim.api.nvim_create_autocmd({ 'BufEnter', 'BufFilePost', 'BufWritePost' }, {
		group = group,
		pattern = '*',
		desc = 'Mark that user navigated into at least one real file or terminal buffer',
		callback = function(ev)
			if is_real_buffer(ev.buf) then
				state.left_alpha = true
			end
		end,
	})

	vim.api.nvim_create_autocmd('SessionLoadPost', {
		group = group,
		pattern = '*',
		desc = 'Clear Alpha dashboard guard once a session finishes loading',
		callback = function()
			state.started_on_alpha = false
			if #collect_real_buffers() > 0 then
				state.left_alpha = true
			end
		end,
	})

	vim.api.nvim_create_autocmd('VimLeavePre', {
		group = group,
		pattern = '*',
		desc = 'Save session into rolling 25-entry history on exit',
		callback = function()
			M.save()
		end,
	})
end

return M
